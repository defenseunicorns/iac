###########################################################
################## Global Settings ########################

variable "region" {
  description = "The AWS region to deploy into"
  type        = string
}

variable "region2" {
  description = "The AWS region to deploy into"
  type        = string
}

variable "account" {
  description = "The AWS account to deploy into"
  type        = string
}

variable "aws_profile" {
  description = "The AWS profile to use for deployment"
  type        = string
}

variable "aws_admin_usernames" {
  description = "A list of one or more AWS usernames with authorized access to KMS and EKS resources"
  type        = list(string)
}

###########################################################
#################### VPC Config ###########################

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "The name to use for the VPC"
  type        = string
  default     = "my-vpc"
}

variable "create_database_subnet_group" {
  description = "Whether to create a database subnet group"
  type        = bool
  default     = true
}

variable "create_database_subnet_route_table" {
  description = "Whether to create a database subnet route table"
  type        = bool
  default     = true
}

###########################################################
#################### EKS Config ###########################

variable "cluster_name" {
  description = "The name to use for the EKS cluster"
  type        = string
  default     = "my-eks"
}

variable "eks_k8s_version" {
  description = "The Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.23"
  validation {
    condition     = contains(["1.23"], var.eks_k8s_version)
    error_message = "Kubernetes version must be equal to one that we support. Currently supported versions are: 1.23."
  }
}

variable "cluster_endpoint_public_access" {
  description = "Whether to enable private access to the EKS cluster"
  type        = bool
  default     = false
}

###########################################################
################## Bastion Config #########################

variable "bastion_name" {
  description = "The name to use for the bastion"
  type        = string
  default     = "my-bastion"
}

variable "bastion_instance_type" {
  description = "value for the instance type of the EKS worker nodes"
  type        = string
  default     = "m5.xlarge"
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP to the bastion"
  type        = bool
  default     = false
}

variable "bastion_ami_id" {
  description = "(Optional) The AMI ID to use for the bastion, will query the latest Amazon Linux 2 AMI if not provided"
  type        = string
  default     = ""
}
variable "bastion_ssh_user" {
  description = "The SSH user to use for the bastion"
  type        = string
  default     = "ec2-user"
}

variable "bastion_ssh_password" {
  description = "The SSH password to use for the bastion if SSM authentication is used"
  type        = string
  default     = "my-password"
}

###########################################################
############## Big Bang Dependencies ######################

variable "keycloak_enabled" {
  description = "Whether to enable Keycloak"
  type        = bool
  default     = false
}

#################### Keycloak ###########################

variable "keycloak_db_password" {
  description = "The password to use for the Keycloak database"
  type        = string
  default     = "my-password"
}

variable "kc_db_engine_version" {
  description = "The database engine to use for Keycloak"
  type        = string
}

variable "kc_db_family" {
  description = "The database family to use for Keycloak"
  type        = string
}

variable "kc_db_major_engine_version" {
  description = "The database major engine version to use for Keycloak"
  type        = string
}

variable "kc_db_instance_class" {
  description = "The database instance class to use for Keycloak"
  type        = string
}

variable "kc_db_allocated_storage" {
  description = "The database allocated storage to use for Keycloak"
  type        = number
}

variable "kc_db_max_allocated_storage" {
  description = "The database allocated storage to use for Keycloak"
  type        = number
}

variable "vpc_instance_tenancy" {
  description = "The tenancy of instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "bastion_tenancy" {
  description = "The tenancy of the bastion"
  type        = string
  default     = "default"
}

variable "eks_worker_tenancy" {
  description = "The tenancy of the EKS worker nodes"
  type        = string
  default     = "default"
}

variable "zarf_version" {
  description = "The version of Zarf to use"
  type        = string
  default     = ""
}
