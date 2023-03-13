# Bastion Module

This repository contains Terraform configuration files that create an AWS EC2 instance using a hardened AMI, assigns it to a security group, and attaches it to a subnet. This is for secure access into a private subnet via a hardened device. It also creates an SSH key pair for the instance and an IAM instance profile with an optional role. Additionally, it creates an optional KMS key and security group for event queue.

## Examples

To view examples for how you can leverage this Bastion, please see the [examples](https://github.com/defenseunicorns/iac/tree/main/examples) directory.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72 |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudtrail.ssh-access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_cloudwatch_event_rule.ssh-access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.ssm-target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.ec2_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.session_manager_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.ssh-access-log-group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_instance_profile.bastion_ssm_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3_logging_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3_readonly_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ssm_ec2_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ssm_s3_cwl_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.terraform_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.bastion_ssm_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.bastion-ssm-amazon-policy-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.bastion-ssm-ec2-access-policy-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.bastion-ssm-s3-cwl-policy-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3_companion_cube](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3_logging_cube](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_key_pair.bastion_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_kms_alias.ssmkey](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.ssmkey](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_network_interface_attachment.attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface_attachment) | resource |
| [aws_s3_bucket.access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.session_logs_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.session_logs_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_lifecycle_configuration.access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.session_logs_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.access_logging_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_logging.session_logs_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_notification.access_log_bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_notification.session_logs_bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_policy.cloudwatch-s3-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.session_logs_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.session_logs_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.session_logs_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_security_group.sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_sqs_queue.queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_ssm_document.session_manager_prefs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_document) | resource |
| [aws_ssm_parameter.cloudwatch_configuration_file](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [tls_private_key.bastion_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_ami.from_filter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy.AmazonSSMManagedInstanceCore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.cloudwatch-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ssm_ec2_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ssm_s3_cwl_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.subnet_by_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [cloudinit_config.config](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_log_bucket_name_prefix"></a> [access\_log\_bucket\_name\_prefix](#input\_access\_log\_bucket\_name\_prefix) | Name prefix of S3 bucket to store access logs from session logs bucket | `string` | n/a | yes |
| <a name="input_access_log_expire_days"></a> [access\_log\_expire\_days](#input\_access\_log\_expire\_days) | Number of days to wait before deleting access logs | `number` | `30` | no |
| <a name="input_acl"></a> [acl](#input\_acl) | The canned ACL to apply. Defaults to 'private' | `string` | `"private"` | no |
| <a name="input_add_sops_policy"></a> [add\_sops\_policy](#input\_add\_sops\_policy) | value of the policy arn for the cluster sops policy | `bool` | `false` | no |
| <a name="input_additional_user_data_script"></a> [additional\_user\_data\_script](#input\_additional\_user\_data\_script) | n/a | `string` | `""` | no |
| <a name="input_allowed_public_ips"></a> [allowed\_public\_ips](#input\_allowed\_public\_ips) | List of public IPs to allow SSH access from | `list(string)` | `[]` | no |
| <a name="input_ami_canonical_owner"></a> [ami\_canonical\_owner](#input\_ami\_canonical\_owner) | Filter for AMI using this canonical owner ID | `string` | `null` | no |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | ID of AMI to use for Bastion | `string` | `""` | no |
| <a name="input_ami_name_filter"></a> [ami\_name\_filter](#input\_ami\_name\_filter) | Filter for AMI using this name. Accepts wildcards | `string` | `""` | no |
| <a name="input_ami_virtualization_type"></a> [ami\_virtualization\_type](#input\_ami\_virtualization\_type) | Filter for AMI using this virtualization type | `string` | `""` | no |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Determines if an instance gets a public IP assigned at launch time | `bool` | `false` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_bucket_public_access_block"></a> [bucket\_public\_access\_block](#input\_bucket\_public\_access\_block) | Toggle to optionally block public s3 access. Defaults to true | `bool` | `true` | no |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | Name of the CloudWatch Log Group for storing SSM Session Logs | `string` | `"/ssm/session-logs"` | no |
| <a name="input_cloudwatch_logs_retention"></a> [cloudwatch\_logs\_retention](#input\_cloudwatch\_logs\_retention) | Number of days to retain Session Logs in CloudWatch | `number` | `30` | no |
| <a name="input_cluster_sops_policy_arn"></a> [cluster\_sops\_policy\_arn](#input\_cluster\_sops\_policy\_arn) | value of the policy arn for the cluster sops policy | `string` | `""` | no |
| <a name="input_ec2_key_name"></a> [ec2\_key\_name](#input\_ec2\_key\_name) | Name of keypair to associate with instance | `string` | `null` | no |
| <a name="input_enable_event_queue"></a> [enable\_event\_queue](#input\_enable\_event\_queue) | Toggle to optionally generate events on object writes, and add them to an SQS queue. Defaults to false | `bool` | `false` | no |
| <a name="input_enable_hourly_cron_updates"></a> [enable\_hourly\_cron\_updates](#input\_enable\_hourly\_cron\_updates) | n/a | `string` | `"false"` | no |
| <a name="input_enable_kms_key_rotation"></a> [enable\_kms\_key\_rotation](#input\_enable\_kms\_key\_rotation) | Toggle to optionally enable kms key rotation. Defaults to true | `bool` | `true` | no |
| <a name="input_enable_log_to_cloudwatch"></a> [enable\_log\_to\_cloudwatch](#input\_enable\_log\_to\_cloudwatch) | Enable Session Manager to Log to CloudWatch Logs | `bool` | `true` | no |
| <a name="input_enable_log_to_s3"></a> [enable\_log\_to\_s3](#input\_enable\_log\_to\_s3) | Enable Session Manager to Log to S3 | `bool` | `true` | no |
| <a name="input_eni_attachment_config"></a> [eni\_attachment\_config](#input\_eni\_attachment\_config) | Optional list of enis to attach to instance | <pre>list(object({<br>    network_interface_id = string<br>    device_index         = string<br>  }))</pre> | `null` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error | `bool` | `true` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type to use for Bastion | `string` | `"m5.large"` | no |
| <a name="input_keys_update_frequency"></a> [keys\_update\_frequency](#input\_keys\_update\_frequency) | n/a | `string` | `""` | no |
| <a name="input_kms_key_alias"></a> [kms\_key\_alias](#input\_kms\_key\_alias) | Alias prefix of the KMS key.  Must start with alias/ followed by a name | `string` | `"alias/ssm-key"` | no |
| <a name="input_kms_key_deletion_window"></a> [kms\_key\_deletion\_window](#input\_kms\_key\_deletion\_window) | Waiting period for scheduled KMS Key deletion.  Can be 7-30 days. | `number` | `7` | no |
| <a name="input_linux_shell_profile"></a> [linux\_shell\_profile](#input\_linux\_shell\_profile) | The ShellProfile to use for linux based machines. | `string` | `""` | no |
| <a name="input_log_archive_days"></a> [log\_archive\_days](#input\_log\_archive\_days) | Number of days to wait before archiving to Glacier | `number` | `30` | no |
| <a name="input_log_expire_days"></a> [log\_expire\_days](#input\_log\_expire\_days) | Number of days to wait before deleting | `number` | `365` | no |
| <a name="input_logging"></a> [logging](#input\_logging) | Map containing access bucket logging configuration. | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of Bastion | `string` | n/a | yes |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | (Optional) The ARN of the policy that is used to set the permissions boundary for the role. | `string` | `null` | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | List of IAM policy ARNs to attach to the instance profile | `list(string)` | `[]` | no |
| <a name="input_policy_content"></a> [policy\_content](#input\_policy\_content) | Policy body. Use this to add a custom policy to your instance profile (Optional) | `string` | `""` | no |
| <a name="input_requires_eip"></a> [requires\_eip](#input\_requires\_eip) | Whether or not the instance should have an Elastic IP associated to it | `bool` | `false` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name to give IAM role created for instance profile | `string` | `""` | no |
| <a name="input_root_volume_config"></a> [root\_volume\_config](#input\_root\_volume\_config) | n/a | <pre>object({<br>    volume_type = any<br>    volume_size = any<br>  })</pre> | <pre>{<br>  "volume_size": "20",<br>  "volume_type": "gp3"<br>}</pre> | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security groups to associate with instance | `list(any)` | `[]` | no |
| <a name="input_session_log_bucket_name_prefix"></a> [session\_log\_bucket\_name\_prefix](#input\_session\_log\_bucket\_name\_prefix) | Name prefix of S3 bucket to store session logs | `string` | n/a | yes |
| <a name="input_ssh_password"></a> [ssh\_password](#input\_ssh\_password) | Password for SSH access if SSM authentication is enabled | `string` | n/a | yes |
| <a name="input_ssh_public_key_names"></a> [ssh\_public\_key\_names](#input\_ssh\_public\_key\_names) | n/a | `list(string)` | <pre>[<br>  "user1",<br>  "user2",<br>  "admin"<br>]</pre> | no |
| <a name="input_ssh_user"></a> [ssh\_user](#input\_ssh\_user) | n/a | `string` | `"ubuntu"` | no |
| <a name="input_ssm_enabled"></a> [ssm\_enabled](#input\_ssm\_enabled) | Enable SSM agent | `bool` | `true` | no |
| <a name="input_ssmkey_arn"></a> [ssmkey\_arn](#input\_ssmkey\_arn) | SSM key arn | `string` | `""` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | IDs of subnets to deploy the instance in | `string` | `""` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Names of subnets to deploy the instance in | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_tenancy"></a> [tenancy](#input\_tenancy) | The tenancy of the instance (if the instance is running in a VPC). Valid values are 'default' or 'dedicated'. | `string` | `"default"` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | (Optional) The user data to provide when launching the instance | `string` | `""` | no |
| <a name="input_user_data_file"></a> [user\_data\_file](#input\_user\_data\_file) | n/a | `string` | `"templates/user_data.sh"` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Enable versioning. Once you version-enable a bucket, it can never return to an unversioned state. You can, however, suspend versioning on that bucket. | `bool` | `true` | no |
| <a name="input_vpc_endpoints_enabled"></a> [vpc\_endpoints\_enabled](#input\_vpc\_endpoints\_enabled) | Create VPC Endpoints | `bool` | `true` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id | `string` | n/a | yes |
| <a name="input_windows_shell_profile"></a> [windows\_shell\_profile](#input\_windows\_shell\_profile) | The ShellProfile to use for windows based machines. | `string` | `""` | no |
| <a name="input_zarf_version"></a> [zarf\_version](#input\_zarf\_version) | The version of Zarf to use | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_bucket_arn"></a> [access\_bucket\_arn](#output\_access\_bucket\_arn) | Access Bucket ARN |
| <a name="output_access_bucket_name"></a> [access\_bucket\_name](#output\_access\_bucket\_name) | Access Bucket Name |
| <a name="output_bastion_role_arn"></a> [bastion\_role\_arn](#output\_bastion\_role\_arn) | Bastion Role ARN |
| <a name="output_bastion_role_name"></a> [bastion\_role\_name](#output\_bastion\_role\_name) | Bastion Role Name |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | Instance Id |
| <a name="output_primary_network_interface_id"></a> [primary\_network\_interface\_id](#output\_primary\_network\_interface\_id) | Primary Network Interface Id |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | Private IP |
| <a name="output_private_key"></a> [private\_key](#output\_private\_key) | n/a |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | Public IP |
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids) | Security Group Ids |
| <a name="output_session_logs_bucket_arn"></a> [session\_logs\_bucket\_arn](#output\_session\_logs\_bucket\_arn) | Session Logs Bucket ARN |
| <a name="output_session_logs_bucket_name"></a> [session\_logs\_bucket\_name](#output\_session\_logs\_bucket\_name) | Session Logs Bucket Name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
