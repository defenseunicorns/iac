data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_partition" "current" {}

#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------

module "eks_blueprints" {
  # pending approval of [PR](https://github.com/aws-ia/terraform-aws-eks-blueprints/issues/1387)
  source = "git::https://github.com/ntwkninja/terraform-aws-eks-blueprints.git?ref=v4.21.1"

  cluster_name    = local.cluster_name
  cluster_version = var.eks_k8s_version

  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  # public_subnet_ids  = var.public_subnet_ids
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  control_plane_subnet_ids        = var.control_plane_subnet_ids

  self_managed_node_groups = var.self_managed_node_groups
  # managed_node_groups      = var.managed_node_groups

  #----------------------------------------------------------------------------------------------------------#
  # Security groups used in this module created by the upstream modules terraform-aws-eks (https://github.com/terraform-aws-modules/terraform-aws-eks).
  #   Upstream module implemented Security groups based on the best practices doc https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html.
  #   So, by default the security groups are restrictive. Users needs to enable rules for specific ports required for App requirement or Add-ons
  #   See the notes below for each rule used in these examples
  #----------------------------------------------------------------------------------------------------------#
  cluster_security_group_additional_rules = {
    ingress_bastion_to_cluster = {
      # name        = "allow bastion ingress to cluster"
      description              = "Bastion SG to Cluster"
      security_group_id        = module.eks_blueprints.cluster_security_group_id
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      type                     = "ingress"
      source_security_group_id = var.source_security_group_id
    }
  }

  node_security_group_additional_rules = {
    # Extend node-to-node security group rules. Recommended and required for the Add-ons
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    # Recommended outbound traffic for Node groups
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
    }
    # Allows Control Plane Nodes to talk to Worker nodes on all ports. Added this to simplify the example and further avoid issues with Add-ons communication with Control plane.
    # This can be restricted further to specific port based on the requirement for each Add-on e.g., metrics-server 4443, spark-operator 8080, karpenter 8443 etc.
    # Change this according to your security requirements if needed
    ingress_cluster_to_node_all_traffic = {
      description                   = "Cluster API to Nodegroup all traffic"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  cluster_kms_key_additional_admin_arns = var.cluster_kms_key_additional_admin_arns

  map_users = var.aws_auth_eks_map_users
  map_roles = [
    {
      rolearn  = aws_iam_role.auth_eks_role.arn
      username = aws_iam_role.auth_eks_role.name
      groups   = ["system:masters"]
    },
    {
      rolearn  = var.bastion_role_arn
      username = var.bastion_role_name
      groups   = ["system:masters"]
    }
  ]
}
#---------------------------------------------------------------
# Custom IAM role for Self Managed Node Group
#---------------------------------------------------------------
data "aws_iam_policy_document" "self_managed_ng_assume_role_policy" {
  statement {
    sid = "EKSWorkerAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "self_managed_ng" {
  name                  = "${var.name}-self-managed-node-role"
  description           = "EKS Managed Node group IAM Role"
  assume_role_policy    = data.aws_iam_policy_document.self_managed_ng_assume_role_policy.json
  path                  = "/"
  force_detach_policies = true
  managed_policy_arns = [
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  tags = local.tags
}

resource "aws_iam_instance_profile" "self_managed_ng" {
  name = "${var.name}-self-managed-node-instance-profile"
  role = aws_iam_role.self_managed_ng.name
  path = "/"

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

resource "aws_iam_role" "auth_eks_role" {
  name               = "${var.name}-auth-eks-role"
  description        = "EKS AuthConfig Role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "AWS": ${var.cluster_kms_key_additional_admin_arns == [] ? "[]" : jsonencode(var.cluster_kms_key_additional_admin_arns)}
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF

}
