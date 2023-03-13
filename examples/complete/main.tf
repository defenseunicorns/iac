data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_ami" "amazonlinux2eks" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.eks_k8s_version}-*"]
  }

  owners = ["amazon"]
}

resource "random_id" "vpc_name" {
  byte_length = 2
  prefix      = var.vpc_name_prefix
}

resource "random_id" "cluster_name" {
  byte_length = 2
  prefix      = var.cluster_name_prefix
}

resource "random_id" "bastion_name" {
  byte_length = 2
  prefix      = var.bastion_name_prefix
}

locals {
  vpc_name                   = lower(random_id.vpc_name.hex)
  cluster_name               = lower(random_id.cluster_name.hex)
  bastion_name               = lower(random_id.bastion_name.hex)
  loki_s3_bucket_name_prefix = "${lower(random_id.cluster_name.hex)}-loki-s3"

  account = data.aws_caller_identity.current.account_id

  tags = {
    Blueprint  = "${replace(basename(path.cwd), "_", "-")}" # tag names based on the directory name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
  admin_arns = [for admin_user in var.aws_admin_usernames : "arn:${data.aws_partition.current.partition}:iam::${local.account}:user/${admin_user}"]
  aws_auth_eks_map_users = [for admin_user in var.aws_admin_usernames : {
    userarn  = "arn:${data.aws_partition.current.partition}:iam::${local.account}:user/${admin_user}"
    username = "${admin_user}"
    groups   = ["system:masters"]
    }
  ]

  managed_node_groups = var.enable_managed_nodegroups == false ? tomap({}) : {
    # Managed Node groups with minimum config
    mg5 = {
      node_group_name = "mg5"
      instance_types  = ["m5.large"]
      min_size        = 2
      create_iam_role = false # Changing `create_iam_role=false` to bring your own IAM Role
      iam_role_arn    = module.eks.aws_iam_role_managed_ng_arn
      disk_size       = 100 # Disk size is used only with Managed Node Groups without Launch Templates
      update_config = [{
        max_unavailable_percentage = 30
      }]
    },
    # Managed Node groups with Launch templates using AMI TYPE
    mng_lt = {
      # Node Group configuration
      node_group_name = "mng_lt" # Max 40 characters for node group name

      ami_type               = "AL2_x86_64"  # Available options -> AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
      release_version        = ""            # Enter AMI release version to deploy the latest AMI released by AWS. Used only when you specify ami_type
      capacity_type          = "ON_DEMAND"   # ON_DEMAND or SPOT
      instance_types         = ["r5d.large"] # List of instances used only for SPOT type
      format_mount_nvme_disk = true          # format and mount NVMe disks ; default to false

      # Launch template configuration
      create_launch_template = true              # false will use the default launch template
      launch_template_os     = "amazonlinux2eks" # amazonlinux2eks or bottlerocket

      enable_monitoring = true
      eni_delete        = true
      public_ip         = false # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates

      http_endpoint               = "enabled"
      http_tokens                 = "optional"
      http_put_response_hop_limit = 3

      # pre_userdata can be used in both cases where you provide custom_ami_id or ami_type
      pre_userdata = <<-EOT
        yum install -y amazon-ssm-agent
        systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent
      EOT

      # Taints can be applied through EKS API or through Bootstrap script using kubelet_extra_args
      # e.g., k8s_taints = [{key= "spot", value="true", "effect"="NO_SCHEDULE"}]
      k8s_taints = []

      # Node Labels can be applied through EKS API or through Bootstrap script using kubelet_extra_args
      k8s_labels = {
        Environment = "preprod"
        Zone        = "dev"
        Runtime     = "docker"
      }

      # Node Group scaling configuration
      desired_size = 2
      max_size     = 2
      min_size     = 2

      block_device_mappings = [
        {
          device_name = "/dev/xvda"
          volume_type = "gp3"
          volume_size = 100
        }
      ]

      # Node Group network configuration
      subnet_type = "private" # public or private - Default uses the private subnets used in control plane if you don't pass the "subnet_ids"
      subnet_ids  = []        # Defaults to private subnet-ids used by EKS Control plane. Define your private/public subnets list with comma separated subnet_ids  = ['subnet1','subnet2','subnet3']

      additional_iam_policies = [] # Attach additional IAM policies to the IAM role attached to this worker group

      # SSH ACCESS Optional - Recommended to use SSM Session manager
      remote_access         = false
      ec2_ssh_key           = ""
      ssh_security_group_id = ""

      additional_tags = {
        ExtraTag    = "m5x-on-demand"
        Name        = "m5x-on-demand"
        subnet_type = "private"
      }
    }
    # Managed Node groups with Launch templates using CUSTOM AMI with ContainerD runtime
    mng_custom_ami = {
      # Node Group configuration
      node_group_name = "mng_custom_ami" # Max 40 characters for node group name

      # custom_ami_id is optional when you provide ami_type. Enter the Custom AMI id if you want to use your own custom AMI
      custom_ami_id  = data.aws_ami.amazonlinux2eks.id
      capacity_type  = "ON_DEMAND"   # ON_DEMAND or SPOT
      instance_types = ["r5d.large"] # List of instances used only for SPOT type

      # Launch template configuration
      create_launch_template = true              # false will use the default launch template
      launch_template_os     = "amazonlinux2eks" # amazonlinux2eks or bottlerocket

      # pre_userdata will be applied by using custom_ami_id or ami_type
      pre_userdata = <<-EOT
        yum install -y amazon-ssm-agent
        systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent
      EOT

      # post_userdata will be applied only by using custom_ami_id
      post_userdata = <<-EOT
        echo "Bootstrap successfully completed! You can further apply config or install to run after bootstrap if needed"
      EOT

      # kubelet_extra_args used only when you pass custom_ami_id;
      # --node-labels is used to apply Kubernetes Labels to Nodes
      # --register-with-taints used to apply taints to Nodes
      # e.g., kubelet_extra_args='--node-labels=WorkerType=SPOT,noderole=spark --register-with-taints=spot=true:NoSchedule --max-pods=58',
      kubelet_extra_args = "--node-labels=WorkerType=SPOT,noderole=spark --register-with-taints=test=true:NoSchedule --max-pods=20"

      # bootstrap_extra_args used only when you pass custom_ami_id. Allows you to change the Container Runtime for Nodes
      # e.g., bootstrap_extra_args="--use-max-pods false --container-runtime containerd"
      bootstrap_extra_args = "--use-max-pods false --container-runtime containerd"

      # Taints can be applied through EKS API or through Bootstrap script using kubelet_extra_args
      k8s_taints = []

      # Node Labels can be applied through EKS API or through Bootstrap script using kubelet_extra_args
      k8s_labels = {
        Environment = "preprod"
        Zone        = "dev"
        Runtime     = "containerd"
      }

      enable_monitoring = true
      eni_delete        = true
      public_ip         = false # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates

      # Node Group scaling configuration
      desired_size = 2
      max_size     = 2
      min_size     = 2

      block_device_mappings = [
        {
          device_name = "/dev/xvda"
          volume_type = "gp3"
          volume_size = 150
        }
      ]

      # Node Group network configuration
      subnet_type = "private" # public or private - Default uses the private subnets used in control plane if you don't pass the "subnet_ids"
      subnet_ids  = []        # Defaults to private subnet-ids used by EKS Control plane. Define your private/public subnets list with comma separated subnet_ids  = ['subnet1','subnet2','subnet3']

      additional_iam_policies = [] # Attach additional IAM policies to the IAM role attached to this worker group

      # SSH ACCESS Optional - Recommended to use SSM Session manager
      remote_access         = false
      ec2_ssh_key           = ""
      ssh_security_group_id = ""

      additional_tags = {
        ExtraTag    = "mng-custom-ami"
        Name        = "mng-custom-ami"
        subnet_type = "private"
      }
    }
    # Managed Node group with Launch templates using AMI TYPE and SPOT instances of 2 vCPUs and 8 Gib Memory
    spot_2vcpu_8mem = {
      node_group_name = "mng-spot-2vcpu-8mem"
      capacity_type   = "SPOT"
      instance_types  = ["m5.large", "m4.large", "m6a.large", "m5a.large", "m5d.large"]
      max_size        = 2
      desired_size    = 1
      min_size        = 1

      # Node Group network configuration
      subnet_type = "private" # public or private - Default uses the private subnets used in control plane if you don't pass the "subnet_ids"
      subnet_ids  = []        # Defaults to private subnet-ids used by EKS Control plane. Define your private/public subnets list with comma separated subnet_ids  = ['subnet1','subnet2','subnet3']

      k8s_taints = [{ key = "spotInstance", value = "true", effect = "NO_SCHEDULE" }]
    }

    # Managed Node group with Launch templates using AMI TYPE and SPOT instances of 4 vCPUs and 16 Gib Memory
    spot_4vcpu_16mem = {
      node_group_name = "mng-spot-4vcpu-16mem"
      capacity_type   = "SPOT"
      instance_types  = ["m5.xlarge", "m4.xlarge", "m6a.xlarge", "m5a.xlarge", "m5d.xlarge"]

      # Node Group network configuration
      subnet_type = "private" # public or private - Default uses the private subnets used in control plane if you don't pass the "subnet_ids"
      subnet_ids  = []        # Defaults to private subnet-ids used by EKS Control plane. Define your private/public subnets list with comma separated subnet_ids  = ['subnet1','subnet2','subnet3']

      k8s_taints = [{ key = "spotInstance", value = "true", effect = "NO_SCHEDULE" }]

      # NOTE: If we want the node group to scale-down to zero nodes,
      # we need to use a custom launch template and define some additional tags for the ASGs
      min_size = 0

      # Launch template configuration
      create_launch_template = true              # false will use the default launch template
      launch_template_os     = "amazonlinux2eks" # amazonlinux2eks or bottlerocket

      # This is so cluster autoscaler can identify which node (using ASGs tags) to scale-down to zero nodes
      additional_tags = {
        "k8s.io/cluster-autoscaler/node-template/label/eks.amazonaws.com/capacityType" = "SPOT"
        "k8s.io/cluster-autoscaler/node-template/label/eks/node_group_name"            = "mng-spot-2vcpu-8mem"
      }
    }
  }

  self_managed_node_groups = var.enable_managed_nodegroups == true ? tomap({}) : {
    self_mg1 = {
      node_group_name        = "self_mg1"
      subnet_ids             = module.vpc.private_subnets
      create_launch_template = true
      launch_template_os     = "amazonlinux2eks" # amazonlinux2eks or bottlerocket or windows
      custom_ami_id          = ""                # Bring your own custom AMI generated by Packer/ImageBuilder/Puppet etc.

      create_iam_role           = false                                                    # Changing `create_iam_role=false` to bring your own IAM Role
      iam_role_arn              = module.eks.aws_iam_role_self_managed_ng_arn              # custom IAM role for aws-auth mapping; used when create_iam_role = false
      iam_instance_profile_name = module.eks.aws_iam_instance_profile_self_managed_ng_name # IAM instance profile name for Launch templates; used when create_iam_role = false

      format_mount_nvme_disk = true
      public_ip              = false
      enable_monitoring      = false

      placement = {
        affinity          = null
        availability_zone = null
        group_name        = null
        host_id           = null
        tenancy           = var.eks_worker_tenancy
      }

      enable_metadata_options = false

      pre_userdata = <<-EOT
        yum install -y amazon-ssm-agent
        systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent
      EOT

      # bootstrap_extra_args used only when you pass custom_ami_id. Allows you to change the Container Runtime for Nodes
      # e.g., bootstrap_extra_args="--use-max-pods false --container-runtime containerd"
      bootstrap_extra_args = "--use-max-pods false"

      block_device_mappings = [
        {
          device_name = "/dev/xvda" # mount point to /
          volume_type = "gp3"
          volume_size = 50
        },
        {
          device_name = "/dev/xvdf" # mount point to /local1 (it could be local2, depending upon the disks are attached during boot)
          volume_type = "gp3"
          volume_size = 80
          iops        = 3000
          throughput  = 125
        },
        {
          device_name = "/dev/xvdg" # mount point to /local2 (it could be local1, depending upon the disks are attached during boot)
          volume_type = "gp3"
          volume_size = 100
          iops        = 3000
          throughput  = 125
        }
      ]

      instance_type = "m5.xlarge"
      desired_size  = 3
      max_size      = 10
      min_size      = 3
      capacity_type = "" # Optional Use this only for SPOT capacity as  capacity_type = "spot"

      k8s_labels = {
        Environment = "preprod"
        Zone        = "test"
      }

      additional_tags = {
        ExtraTag    = "m5x-on-demand"
        Name        = "m5x-on-demand"
        subnet_type = "private"
      }
    }
  }
}

###########################################################
####################### VPC ###############################

module "vpc" {
  # source = "git::https://github.com/defenseunicorns/iac.git//modules/vpc?ref=v<insert tagged version>"
  source = "../../modules/vpc"

  region             = var.region
  name               = local.vpc_name
  vpc_cidr           = var.vpc_cidr
  azs                = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets     = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 5, k)]
  private_subnets    = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 5, k + 4)]
  database_subnets   = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 5, k + 8)]
  single_nat_gateway = true
  enable_nat_gateway = true

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
  create_database_subnet_group       = true
  create_database_subnet_route_table = true

  instance_tenancy = var.vpc_instance_tenancy # dedicated tenancy globally set in VPC does not currently work with EKS
}

###########################################################
##################### Bastion #############################

data "aws_ami" "amazonlinux2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*x86_64-gp2"]
  }

  owners = ["amazon"]
}

module "bastion" {
  # source = "git::https://github.com/defenseunicorns/iac.git//modules/bastion?ref=v<insert tagged version>"
  source = "../../modules/bastion"

  ami_id        = data.aws_ami.amazonlinux2.id
  instance_type = var.bastion_instance_type
  root_volume_config = {
    volume_type = "gp3"
    volume_size = "20"
    encrypted   = true
  }
  name                           = local.bastion_name
  vpc_id                         = module.vpc.vpc_id
  subnet_id                      = module.vpc.private_subnets[0]
  aws_region                     = var.region
  access_log_bucket_name_prefix  = "${local.bastion_name}-accesslogs"
  session_log_bucket_name_prefix = "${local.bastion_name}-sessionlogs"
  ssh_user                       = var.bastion_ssh_user
  ssh_password                   = var.bastion_ssh_password
  assign_public_ip               = false # var.assign_public_ip
  enable_log_to_s3               = true
  enable_log_to_cloudwatch       = true
  vpc_endpoints_enabled          = true
  tenancy                        = var.bastion_tenancy
  zarf_version                   = var.zarf_version
  tags = {
    Function = "bastion-ssm"
  }
}

###########################################################
################### EKS Cluster ###########################
module "eks" {
  # source = "git::https://github.com/defenseunicorns/iac.git//modules/eks?ref=v<insert tagged version>"
  source = "../../modules/eks"

  name                                  = local.cluster_name
  aws_region                            = var.region
  aws_account                           = local.account
  vpc_id                                = module.vpc.vpc_id
  private_subnet_ids                    = module.vpc.private_subnets
  control_plane_subnet_ids              = module.vpc.private_subnets
  source_security_group_id              = module.bastion.security_group_ids[0]
  cluster_endpoint_public_access        = var.cluster_endpoint_public_access
  cluster_endpoint_private_access       = true
  cluster_kms_key_additional_admin_arns = local.admin_arns
  eks_k8s_version                       = var.eks_k8s_version
  bastion_role_arn                      = module.bastion.bastion_role_arn
  bastion_role_name                     = module.bastion.bastion_role_name
  aws_auth_eks_map_users                = local.aws_auth_eks_map_users
  enable_managed_nodegroups             = var.enable_managed_nodegroups
  managed_node_groups                   = local.managed_node_groups
  self_managed_node_groups              = local.self_managed_node_groups

  #---------------------------------------------------------------
  # EKS Blueprints - EKS Add-Ons
  #---------------------------------------------------------------

  enable_eks_vpc_cni        = true
  enable_eks_coredns        = true
  enable_eks_kube_proxy     = true
  enable_eks_ebs_csi_driver = true
  enable_eks_metrics_server = true

  enable_eks_cluster_autoscaler = true
  cluster_autoscaler_helm_config = {
    set = [
      {
        name  = "extraArgs.expander"
        value = "priority"
      },
      {
        name  = "expanderPriorities"
        value = <<-EOT
                  100:
                    - .*-spot-2vcpu-8mem.*
                  90:
                    - .*-spot-4vcpu-16mem.*
                  10:
                    - .*
                EOT
      }
    ]
  }
}
