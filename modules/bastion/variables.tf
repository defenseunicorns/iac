# Global Vars

# variable "aws_profile" {
#   type        = string
#   description = "AWS Profile"
# }

variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "vpc_id" {
  type        = string
  description = "VPC id"
}

### Bastion Module

variable "name" {
  type        = string
  description = "Name of Bastion"
}

variable "instance_type" {
  type        = string
  description = "Instance type to use for Bastion"
  default     = "m5.large"
}

variable "ami_id" {
  type        = string
  description = "ID of AMI to use for Bastion"
  default     = ""
}

variable "allowed_public_ips" {
  type        = list(string)
  description = "List of public IPs to allow SSH access from"
  default     = []
}

variable "ami_name_filter" {
  type        = string
  description = "Filter for AMI using this name. Accepts wildcards"
  default     = ""
}

variable "ami_virtualization_type" {
  type        = string
  description = "Filter for AMI using this virtualization type"
  default     = ""
}

variable "ami_canonical_owner" {
  type        = string
  description = "Filter for AMI using this canonical owner ID"
  default     = null
}

variable "ec2_key_name" {
  type        = string
  description = "Name of keypair to associate with instance"
  default     = null
}

variable "security_group_ids" {
  type        = list(any)
  description = "List of security groups to associate with instance"
  default     = []
}

variable "subnet_id" {
  type        = string
  description = "IDs of subnets to deploy the instance in"
  default     = ""
}

variable "subnet_name" {
  type        = string
  description = "Names of subnets to deploy the instance in"
  default     = ""
}

variable "requires_eip" {
  type        = bool
  description = "Whether or not the instance should have an Elastic IP associated to it"
  default     = false
}

variable "user_data" {
  type        = string
  description = "(Optional) The user data to provide when launching the instance"
  default     = ""
}

variable "role_name" {
  type        = string
  description = "Name to give IAM role created for instance profile"
  default     = ""
}

variable "policy_arns" {
  type        = list(string)
  description = "List of IAM policy ARNs to attach to the instance profile"
  default     = []
}

variable "policy_content" {
  type        = string
  description = "Policy body. Use this to add a custom policy to your instance profile (Optional)"
  default     = ""
}

variable "root_volume_config" {
  type = object({
    volume_type = any
    volume_size = any
  })
  default = {
    volume_type = "gp3"
    volume_size = "20"
  }
}

variable "assign_public_ip" {
  description = "Determines if an instance gets a public IP assigned at launch time"
  type        = bool
  default     = false
}

variable "eni_attachment_config" {
  description = "Optional list of enis to attach to instance"
  type = list(object({
    network_interface_id = string
    device_index         = string
  }))
  default = null
}

variable "permissions_boundary" {
  description = "(Optional) The ARN of the policy that is used to set the permissions boundary for the role."
  type        = string
  default     = null
}

#### S3 Bucket

variable "session_log_bucket_name_prefix" {
  description = "Name prefix of S3 bucket to store session logs"
  type        = string
  validation {
    condition     = length(var.session_log_bucket_name_prefix) <= 37
    error_message = "Bucket name prefixes may not be longer than 37 characters."
  }
}

variable "log_archive_days" {
  description = "Number of days to wait before archiving to Glacier"
  type        = number
  default     = 30
}

variable "log_expire_days" {
  description = "Number of days to wait before deleting"
  type        = number
  default     = 365
}

variable "access_log_bucket_name_prefix" {
  description = "Name prefix of S3 bucket to store access logs from session logs bucket"
  type        = string
  validation {
    condition     = length(var.access_log_bucket_name_prefix) <= 37
    error_message = "Bucket name prefixes may not be longer than 37 characters."
  }
}

variable "access_log_expire_days" {
  description = "Number of days to wait before deleting access logs"
  type        = number
  default     = 30
}

variable "acl" {
  description = "The canned ACL to apply. Defaults to 'private'"
  type        = string
  default     = "private"
}

variable "enable_log_to_s3" {
  description = "Enable Session Manager to Log to S3"
  type        = bool
  default     = true
}

variable "enable_log_to_cloudwatch" {
  description = "Enable Session Manager to Log to CloudWatch Logs"
  type        = bool
  default     = true
}

variable "versioning_enabled" {
  description = "Enable versioning. Once you version-enable a bucket, it can never return to an unversioned state. You can, however, suspend versioning on that bucket."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error"
  type        = bool
  default     = true
}

variable "logging" {
  description = "Map containing access bucket logging configuration."
  type        = map(string)
  default     = {}
}

variable "enable_event_queue" {
  description = "Toggle to optionally generate events on object writes, and add them to an SQS queue. Defaults to false"
  type        = bool
  default     = false
}

variable "enable_kms_key_rotation" {
  description = "Toggle to optionally enable kms key rotation. Defaults to true"
  type        = bool
  default     = true
}

variable "bucket_public_access_block" {
  description = "Toggle to optionally block public s3 access. Defaults to true"
  type        = bool
  default     = true
}

#####################################################
##################### user data #####################


variable "ssh_user" {
  default = "ubuntu"
}

variable "enable_hourly_cron_updates" {
  default = "false"
}

variable "keys_update_frequency" {
  default = ""
}

variable "user_data_file" {
  default = "templates/user_data.sh"
}

variable "additional_user_data_script" {
  default = ""
}

variable "ssh_public_key_names" {
  default = ["user1", "user2", "admin"]
  type    = list(string)
}

variable "cluster_sops_policy_arn" {
  description = "value of the policy arn for the cluster sops policy"
  default     = ""
}

variable "add_sops_policy" {
  description = "value of the policy arn for the cluster sops policy"
  type        = bool
  default     = false
}

variable "ssm_enabled" {
  description = "Enable SSM agent"
  type        = bool
  default     = true
}

variable "ssh_password" {
  description = "Password for SSH access if SSM authentication is enabled"
  type        = string
}

variable "ssmkey_arn" {
  description = "SSM key arn"
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "kms_key_deletion_window" {
  description = "Waiting period for scheduled KMS Key deletion.  Can be 7-30 days."
  type        = number
  default     = 7
}

variable "kms_key_alias" {
  description = "Alias prefix of the KMS key.  Must start with alias/ followed by a name"
  type        = string
  default     = "alias/ssm-key"
}

variable "cloudwatch_logs_retention" {
  description = "Number of days to retain Session Logs in CloudWatch"
  type        = number
  default     = 30
}

variable "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for storing SSM Session Logs"
  type        = string
  default     = "/ssm/session-logs"
}

variable "linux_shell_profile" {
  description = "The ShellProfile to use for linux based machines."
  default     = ""
  type        = string
}

variable "windows_shell_profile" {
  description = "The ShellProfile to use for windows based machines."
  default     = ""
  type        = string
}

variable "vpc_endpoints_enabled" {
  description = "Create VPC Endpoints"
  type        = bool
  default     = true
}

variable "tenancy" {
  description = "The tenancy of the instance (if the instance is running in a VPC). Valid values are 'default' or 'dedicated'."
  type        = string
  default     = "default"
}

variable "zarf_version" {
  description = "The version of Zarf to use"
  type        = string
  default     = ""
}
