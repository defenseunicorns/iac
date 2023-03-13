# AWS EKS Module

This repository contains Terraform configuration files that create an Amazon Elastic Kubernetes Service (EKS) cluster. This module sets various paremeters for this cluster including the cluster name, version, VPC information, security group rules, and user and role mappings. Additionally, it sets up self-managed node groups for the EKS cluster.

## Examples

To view examples for how you can leverage this EKS Module, please see the [examples](https://github.com/defenseunicorns/iac/tree/main/examples) directory.
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.4.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_blueprints"></a> [eks\_blueprints](#module\_eks\_blueprints) | git::https://github.com/aws-ia/terraform-aws-eks-blueprints.git | v4.24.0 |
| <a name="module_eks_blueprints_kubernetes_addons"></a> [eks\_blueprints\_kubernetes\_addons](#module\_eks\_blueprints\_kubernetes\_addons) | git::https://github.com/aws-ia/terraform-aws-eks-blueprints.git//modules/kubernetes-addons | v4.24.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.self_managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.auth_eks_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.self_managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_ami.amazonlinux2eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_iam_policy_document.managed_ng_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.self_managed_ng_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account"></a> [aws\_account](#input\_aws\_account) | n/a | `string` | `""` | no |
| <a name="input_aws_auth_eks_map_users"></a> [aws\_auth\_eks\_map\_users](#input\_aws\_auth\_eks\_map\_users) | List of map of users to add to aws-auth configmap | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | `""` | no |
| <a name="input_bastion_role_arn"></a> [bastion\_role\_arn](#input\_bastion\_role\_arn) | ARN of role authorized kubectl access | `string` | `""` | no |
| <a name="input_bastion_role_name"></a> [bastion\_role\_name](#input\_bastion\_role\_name) | Name of role authorized kubectl access | `string` | `""` | no |
| <a name="input_cluster_autoscaler_helm_config"></a> [cluster\_autoscaler\_helm\_config](#input\_cluster\_autoscaler\_helm\_config) | Helm configuration for Amazon EKS Cluster Autoscaler | `any` | `{}` | no |
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Enable private access to the cluster endpoint | `bool` | `true` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Enable public access to the cluster endpoint | `bool` | `false` | no |
| <a name="input_cluster_kms_key_additional_admin_arns"></a> [cluster\_kms\_key\_additional\_admin\_arns](#input\_cluster\_kms\_key\_additional\_admin\_arns) | List of ARNs of additional users to add to KMS key policy | `list(string)` | `[]` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of cluster - used by Terratest for e2e test automation | `string` | `""` | no |
| <a name="input_control_plane_subnet_ids"></a> [control\_plane\_subnet\_ids](#input\_control\_plane\_subnet\_ids) | Subnet IDs for control plane | `list(string)` | `[]` | no |
| <a name="input_eks_k8s_version"></a> [eks\_k8s\_version](#input\_eks\_k8s\_version) | The Kubernetes version to use for the EKS cluster | `string` | `"1.23"` | no |
| <a name="input_enable_eks_cluster_autoscaler"></a> [enable\_eks\_cluster\_autoscaler](#input\_enable\_eks\_cluster\_autoscaler) | Enable Amazon EKS Cluster Autoscaler | `bool` | `false` | no |
| <a name="input_enable_eks_coredns"></a> [enable\_eks\_coredns](#input\_enable\_eks\_coredns) | Enable Amazon EKS CoreDNS | `bool` | `false` | no |
| <a name="input_enable_eks_ebs_csi_driver"></a> [enable\_eks\_ebs\_csi\_driver](#input\_enable\_eks\_ebs\_csi\_driver) | Enable Amazon EKS EBS CSI Driver | `bool` | `false` | no |
| <a name="input_enable_eks_kube_proxy"></a> [enable\_eks\_kube\_proxy](#input\_enable\_eks\_kube\_proxy) | Enable Amazon EKS Kube Proxy | `bool` | `false` | no |
| <a name="input_enable_eks_metrics_server"></a> [enable\_eks\_metrics\_server](#input\_enable\_eks\_metrics\_server) | Enable Amazon EKS Metrics Server | `bool` | `false` | no |
| <a name="input_enable_eks_node_termination_handler"></a> [enable\_eks\_node\_termination\_handler](#input\_enable\_eks\_node\_termination\_handler) | Enable Amazon EKS Node Termination Handler | `bool` | `false` | no |
| <a name="input_enable_eks_vpc_cni"></a> [enable\_eks\_vpc\_cni](#input\_enable\_eks\_vpc\_cni) | Enable Amazon EKS VPC CNI | `bool` | `false` | no |
| <a name="input_enable_managed_nodegroups"></a> [enable\_managed\_nodegroups](#input\_enable\_managed\_nodegroups) | Enable managed node groups. If false, self managed node groups will be used. | `bool` | n/a | yes |
| <a name="input_managed_node_groups"></a> [managed\_node\_groups](#input\_managed\_node\_groups) | Managed node groups configuration | `any` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `""` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Private subnet IDs | `list(string)` | `[]` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | Public subnet IDs | `list(string)` | `[]` | no |
| <a name="input_self_managed_node_groups"></a> [self\_managed\_node\_groups](#input\_self\_managed\_node\_groups) | Self-managed node groups configuration | `any` | `{}` | no |
| <a name="input_source_security_group_id"></a> [source\_security\_group\_id](#input\_source\_security\_group\_id) | List of additional rules to add to cluster security group | `string` | `""` | no |
| <a name="input_tenancy"></a> [tenancy](#input\_tenancy) | Tenancy of the cluster | `string` | `"dedicated"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_iam_instance_profile_managed_ng_name"></a> [aws\_iam\_instance\_profile\_managed\_ng\_name](#output\_aws\_iam\_instance\_profile\_managed\_ng\_name) | AWS IAM instance profile managed node group name |
| <a name="output_aws_iam_instance_profile_self_managed_ng_name"></a> [aws\_iam\_instance\_profile\_self\_managed\_ng\_name](#output\_aws\_iam\_instance\_profile\_self\_managed\_ng\_name) | AWS IAM instance profile self managed node group name |
| <a name="output_aws_iam_role_managed_ng_arn"></a> [aws\_iam\_role\_managed\_ng\_arn](#output\_aws\_iam\_role\_managed\_ng\_arn) | AWS IAM role managed node group ARN |
| <a name="output_aws_iam_role_self_managed_ng_arn"></a> [aws\_iam\_role\_self\_managed\_ng\_arn](#output\_aws\_iam\_role\_self\_managed\_ng\_arn) | AWS IAM role self managed node group ARN |
| <a name="output_configure_kubectl"></a> [configure\_kubectl](#output\_configure\_kubectl) | Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig |
| <a name="output_eks_cluster_certificate_authority_data"></a> [eks\_cluster\_certificate\_authority\_data](#output\_eks\_cluster\_certificate\_authority\_data) | EKS cluster certificate authority data |
| <a name="output_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#output\_eks\_cluster\_endpoint) | EKS cluster endpoint |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | EKS cluster ID |
| <a name="output_eks_managed_nodegroup_arns"></a> [eks\_managed\_nodegroup\_arns](#output\_eks\_managed\_nodegroup\_arns) | EKS managed node group arns |
| <a name="output_eks_managed_nodegroup_ids"></a> [eks\_managed\_nodegroup\_ids](#output\_eks\_managed\_nodegroup\_ids) | EKS managed node group ids |
| <a name="output_eks_managed_nodegroup_role_name"></a> [eks\_managed\_nodegroup\_role\_name](#output\_eks\_managed\_nodegroup\_role\_name) | EKS managed node group role name |
| <a name="output_eks_managed_nodegroup_status"></a> [eks\_managed\_nodegroup\_status](#output\_eks\_managed\_nodegroup\_status) | EKS managed node group status |
| <a name="output_eks_managed_nodegroups"></a> [eks\_managed\_nodegroups](#output\_eks\_managed\_nodegroups) | EKS managed node groups |
| <a name="output_eks_oidc_provider_arn"></a> [eks\_oidc\_provider\_arn](#output\_eks\_oidc\_provider\_arn) | EKS OIDC provider ARN |
| <a name="output_region"></a> [region](#output\_region) | AWS region |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
