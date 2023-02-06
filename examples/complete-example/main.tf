data "aws_partition" "current" {}

locals {
  tags = {
    Blueprint  = "${replace(basename(path.cwd), "_", "-")}" # tag names based on the directory name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

###########################################################
####################### VPC ###############################

module "vpc" {
  # source = "git::https://github.com/defenseunicorns/iac.git//modules/vpc?ref=v<insert tagged version>"
  source = "../../modules/vpc"

  region           = var.region
  name             = var.vpc_name
  vpc_cidr         = var.vpc_cidr
  azs              = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets   = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 5, k)]
  private_subnets  = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 5, k + 4)]
  database_subnets = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 5, k + 8)]

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  }
  create_database_subnet_group       = true
  create_database_subnet_route_table = true

  instance_tenancy = var.vpc_instance_tenancy # dedicated tenancy globally set in VPC does not currently work with EKS
}

###########################################################
##################### Bastion #############################

module "bastion" {
  # source = "git::https://github.com/defenseunicorns/iac.git//modules/bastion?ref=v<insert tagged version>"
  source = "../../modules/bastion"

  ami_id                   = var.bastion_ami_id
  name                     = var.bastion_name
  vpc_id                   = module.vpc.vpc_id
  subnet_id                = module.vpc.private_subnets[0]
  aws_region               = var.region
  access_log_bucket_name   = "${var.bastion_name}-access-logs"
  bucket_name              = "${var.bastion_name}-session-logs"
  ssh_user                 = var.bastion_ssh_user
  ssh_password             = var.bastion_ssh_password
  assign_public_ip         = false # var.assign_public_ip
  enable_log_to_s3         = true
  enable_log_to_cloudwatch = true
  vpc_endpoints_enabled    = true
  tenancy                  = var.bastion_tenancy
  tags = {
    Function = "bastion-ssm"
  }
}

###########################################################
################### EKS Cluster ###########################
module "eks" {
  # source = "git::https://github.com/defenseunicorns/iac.git//modules/eks?ref=v<insert tagged version>"
  source = "../../modules/eks"

  name                     = var.cluster_name
  aws_region               = var.region
  aws_account              = var.account
  vpc_id                   = module.vpc.vpc_id
  private_subnet_ids       = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets
  source_security_group_id = module.bastion.security_group_ids[0]
  # cluster_endpoint_public_access = true # uncomment this line to enable public access to the EKS control plane (i.e. not require bastion for access)
  # cluster_endpoint_private_access       = false
  cluster_kms_key_additional_admin_arns = ["arn:${data.aws_partition.current.partition}:iam::${var.account}:user/${var.aws_admin_1_username}", "arn:${data.aws_partition.current.partition}:iam::${var.account}:user/${var.aws_admin_2_username}"]
  eks_k8s_version                       = var.eks_k8s_version
  bastion_role_arn                      = module.bastion.bastion_role_arn
  bastion_role_name                     = module.bastion.bastion_role_name
  aws_auth_eks_map_users = [
    {
      userarn  = "arn:${data.aws_partition.current.partition}:iam::${var.account}:user/${var.aws_admin_1_username}"
      username = "${var.aws_admin_1_username}"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:${data.aws_partition.current.partition}:iam::${var.account}:user/${var.aws_admin_2_username}"
      username = "${var.aws_admin_2_username}"
      groups   = ["system:masters"]
    }
  ]

  #---------------------------------------------------------------
  # EKS Blueprints - Self Managed Node Groups
  #---------------------------------------------------------------

  self_managed_node_groups = {
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

  #   }
  #   self_mg5 = {
  #     node_group_name = "self_mg5" # Name is used to create a dedicated IAM role for each node group and adds to AWS-AUTH config map

  #     subnet_type            = "private"
  #     subnet_ids             = var.private_subnet_ids # Optional defaults to Private Subnet Ids used by EKS Control Plane
  #     create_launch_template = true
  #     launch_template_os     = "amazonlinux2eks" # amazonlinux2eks or bottlerocket or windows
  #     custom_ami_id          = ""                # Bring your own custom AMI generated by Packer/ImageBuilder/Puppet etc.

  #     create_iam_role           = false                                         # Changing `create_iam_role=false` to bring your own IAM Role
  #     iam_role_arn              = aws_iam_role.self_managed_ng.arn              # custom IAM role for aws-auth mapping; used when create_iam_role = false
  #     iam_instance_profile_name = aws_iam_instance_profile.self_managed_ng.name # IAM instance profile name for Launch templates; used when create_iam_role = false

  #     format_mount_nvme_disk = true
  #     public_ip              = false
  #     enable_monitoring      = false

  #     enable_metadata_options = false

  #     pre_userdata = <<-EOT
  #       yum install -y amazon-ssm-agent
  #       systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent
  #     EOT

  #     post_userdata = "" # Optional config

  #     # --node-labels is used to apply Kubernetes Labels to Nodes
  #     # --register-with-taints used to apply taints to Nodes
  #     # e.g., kubelet_extra_args='--node-labels=WorkerType=SPOT,noderole=spark --register-with-taints=spot=true:NoSchedule --max-pods=58',
  #     kubelet_extra_args = "--node-labels=WorkerType=SPOT,noderole=spark --register-with-taints=test=true:NoSchedule --max-pods=20"

  #     # bootstrap_extra_args used only when you pass custom_ami_id. Allows you to change the Container Runtime for Nodes
  #     # e.g., bootstrap_extra_args="--use-max-pods false --container-runtime containerd"
  #     bootstrap_extra_args = "--use-max-pods false"

  #     block_device_mappings = [
  #       {
  #         device_name = "/dev/xvda" # mount point to /
  #         volume_type = "gp3"
  #         volume_size = 50
  #       },
  #       {
  #         device_name = "/dev/xvdf" # mount point to /local1 (it could be local2, depending upon the disks are attached during boot)
  #         volume_type = "gp3"
  #         volume_size = 80
  #         iops        = 3000
  #         throughput  = 125
  #       },
  #       {
  #         device_name = "/dev/xvdg" # mount point to /local2 (it could be local1, depending upon the disks are attached during boot)
  #         volume_type = "gp3"
  #         volume_size = 100
  #         iops        = 3000
  #         throughput  = 125
  #       }
  #     ]

  #     instance_type = "m5.large"
  #     desired_size  = 2
  #     max_size      = 10
  #     min_size      = 2
  #     capacity_type = "" # Optional Use this only for SPOT capacity as  capacity_type = "spot"

  #     k8s_labels = {
  #       Environment = "preprod"
  #       Zone        = "test"
  #       WorkerType  = "SELF_MANAGED_ON_DEMAND"
  #     }

  #     additional_tags = {
  #       ExtraTag    = "m5x-on-demand"
  #       Name        = "m5x-on-demand"
  #       subnet_type = "private"
  #     }
  #   }

  #   spot_2vcpu_8mem = {
  #     node_group_name    = "smng-spot-2vcpu-8mem"
  #     capacity_type      = "spot"
  #     capacity_rebalance = true
  #     instance_types     = ["m5.large", "m4.large", "m6a.large", "m5a.large", "m5d.large"]
  #     min_size           = 0
  #     subnet_ids         = var.private_subnet_ids
  #     launch_template_os = "amazonlinux2eks" # amazonlinux2eks or bottlerocket
  #     k8s_taints         = [{ key = "spotInstance", value = "true", effect = "NO_SCHEDULE" }]
  #   }

  #   spot_4vcpu_16mem = {
  #     node_group_name    = "smng-spot-4vcpu-16mem"
  #     capacity_type      = "spot"
  #     capacity_rebalance = true
  #     instance_types     = ["m5.xlarge", "m4.xlarge", "m6a.xlarge", "m5a.xlarge", "m5d.xlarge"]
  #     min_size           = 0
  #     subnet_ids         = var.private_subnet_ids
  #     launch_template_os = "amazonlinux2eks" # amazonlinux2eks or bottlerocket
  #     k8s_taints         = [{ key = "spotInstance", value = "true", effect = "NO_SCHEDULE" }]
  #   }
  # }

  #---------------------------------------------------------------
  # EKS Blueprints - EKS Add-Ons
  #---------------------------------------------------------------

  enable_eks_vpc_cni                  = true
  enable_eks_coredns                  = true
  enable_eks_kube_proxy               = true
  enable_eks_ebs_csi_driver           = true
  enable_eks_metrics_server           = true
  enable_eks_node_termination_handler = true

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
