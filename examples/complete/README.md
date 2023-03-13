# Complete Example: EKS Cluster Deployment with new VPC & Big Bang Dependencies

This example deploys:

- A VPC with:
  - 3 public subnets with internet gateway
  - 3 private subnets with NAT gateway
- An EKS cluster with worker node group(s)
- A Bastion host in one of the private subnets
- Big Bang dependencies:
  - KMS key and IAM roles for SOPS and IRSA
  - S3 bucket for Loki
  - RDS database for Keycloak

> This example has 2 modes: "insecure" and "secure". Insecure mode uses managed nodegroups, default instance tenancy, and enables the public endpoint on the EKS cluster. Secure mode uses self-managed nodegroups, dedicated instance tenancy, and disables the public endpoint on the EKS cluster. The method of choosing which mode to use is by using either `fixtures.insecure.tfvars` or `fixtures.secure.tfvars` as an overlay on top of `fixtures.common.tfvars`.

> NOTE: Secure mode doesn't exist yet. Stay tuned or use the `complete-self-managed-nodegroup` example. Once this example has secure mode available the `complete-self-managed-nodegroup` example will be deprecated/deleted.

## Configure

- If you want access to the cluster, update the `aws_admin_usernames` variable in `fixtures.common.tfvars` to include your IAM username.
  > Easily retrieve your IAM username with `aws iam get-user | jq '.[]' | jq -r '.UserName'`
- Feel free to change other variables to suit your needs.

## Deploy/Destroy

See the [examples README](../README.md) for instructions on how to deploy/destroy this example. The make targets for this example are either `test-complete-insecure` or `test-complete-secure`.

## Connect

### Insecure mode

In insecure mode, the EKS cluster has a public endpoint. You can get the kubeconfig you need to connect to the cluster with the following command:

```shell
aws eks update-kubeconfig --region <RegionYouUsed> --name <ClusterName> --kubeconfig <PathToKubeconfigYouWantToModify> --alias <AliasForTheCluster>
```
> Use `aws eks list-clusters --region <RegionYouUsed>` to get the name of the cluster.

### Secure mode

Coming soon

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.47.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | >= 2.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.5.1 |
| <a name="requirement_http"></a> [http](#requirement\_http) | 2.4.1 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.14.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.1.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.8.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.47.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ../../modules/bastion | n/a |
| <a name="module_eks"></a> [eks](#module\_eks) | ../../modules/eks | n/a |
| <a name="module_flux_sops"></a> [flux\_sops](#module\_flux\_sops) | ../../modules/sops | n/a |
| <a name="module_loki_s3_bucket"></a> [loki\_s3\_bucket](#module\_loki\_s3\_bucket) | ../../modules/s3-irsa | n/a |
| <a name="module_rds_postgres_keycloak"></a> [rds\_postgres\_keycloak](#module\_rds\_postgres\_keycloak) | ../../modules/rds | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../modules/vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [random_id.bastion_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_id.cluster_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_id.vpc_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_ami.amazonlinux2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.amazonlinux2eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Whether to assign a public IP to the bastion | `bool` | `false` | no |
| <a name="input_aws_admin_usernames"></a> [aws\_admin\_usernames](#input\_aws\_admin\_usernames) | A list of one or more AWS usernames with authorized access to KMS and EKS resources | `list(string)` | n/a | yes |
| <a name="input_bastion_instance_type"></a> [bastion\_instance\_type](#input\_bastion\_instance\_type) | value for the instance type of the EKS worker nodes | `string` | `"m5.xlarge"` | no |
| <a name="input_bastion_name_prefix"></a> [bastion\_name\_prefix](#input\_bastion\_name\_prefix) | The name to use for the bastion | `string` | `"my-bastion"` | no |
| <a name="input_bastion_ssh_password"></a> [bastion\_ssh\_password](#input\_bastion\_ssh\_password) | The SSH password to use for the bastion if SSM authentication is used | `string` | `"my-password"` | no |
| <a name="input_bastion_ssh_user"></a> [bastion\_ssh\_user](#input\_bastion\_ssh\_user) | The SSH user to use for the bastion | `string` | `"ec2-user"` | no |
| <a name="input_bastion_tenancy"></a> [bastion\_tenancy](#input\_bastion\_tenancy) | The tenancy of the bastion | `string` | `"default"` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Whether to enable private access to the EKS cluster | `bool` | `false` | no |
| <a name="input_cluster_name_prefix"></a> [cluster\_name\_prefix](#input\_cluster\_name\_prefix) | The name to use for the EKS cluster | `string` | `"my-eks"` | no |
| <a name="input_create_database_subnet_group"></a> [create\_database\_subnet\_group](#input\_create\_database\_subnet\_group) | Whether to create a database subnet group | `bool` | `true` | no |
| <a name="input_create_database_subnet_route_table"></a> [create\_database\_subnet\_route\_table](#input\_create\_database\_subnet\_route\_table) | Whether to create a database subnet route table | `bool` | `true` | no |
| <a name="input_eks_k8s_version"></a> [eks\_k8s\_version](#input\_eks\_k8s\_version) | The Kubernetes version to use for the EKS cluster | `string` | `"1.23"` | no |
| <a name="input_eks_worker_tenancy"></a> [eks\_worker\_tenancy](#input\_eks\_worker\_tenancy) | The tenancy of the EKS worker nodes | `string` | `"default"` | no |
| <a name="input_enable_managed_nodegroups"></a> [enable\_managed\_nodegroups](#input\_enable\_managed\_nodegroups) | Enable managed node groups. If false, self managed node groups will be used. | `bool` | n/a | yes |
| <a name="input_kc_db_allocated_storage"></a> [kc\_db\_allocated\_storage](#input\_kc\_db\_allocated\_storage) | The database allocated storage to use for Keycloak | `number` | n/a | yes |
| <a name="input_kc_db_engine_version"></a> [kc\_db\_engine\_version](#input\_kc\_db\_engine\_version) | The database engine to use for Keycloak | `string` | n/a | yes |
| <a name="input_kc_db_family"></a> [kc\_db\_family](#input\_kc\_db\_family) | The database family to use for Keycloak | `string` | n/a | yes |
| <a name="input_kc_db_instance_class"></a> [kc\_db\_instance\_class](#input\_kc\_db\_instance\_class) | The database instance class to use for Keycloak | `string` | n/a | yes |
| <a name="input_kc_db_major_engine_version"></a> [kc\_db\_major\_engine\_version](#input\_kc\_db\_major\_engine\_version) | The database major engine version to use for Keycloak | `string` | n/a | yes |
| <a name="input_kc_db_max_allocated_storage"></a> [kc\_db\_max\_allocated\_storage](#input\_kc\_db\_max\_allocated\_storage) | The database allocated storage to use for Keycloak | `number` | n/a | yes |
| <a name="input_keycloak_db_password"></a> [keycloak\_db\_password](#input\_keycloak\_db\_password) | The password to use for the Keycloak database | `string` | `"my-password"` | no |
| <a name="input_keycloak_enabled"></a> [keycloak\_enabled](#input\_keycloak\_enabled) | Whether to enable Keycloak | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to deploy into | `string` | n/a | yes |
| <a name="input_region2"></a> [region2](#input\_region2) | The AWS region to deploy into | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The CIDR block for the VPC | `string` | n/a | yes |
| <a name="input_vpc_instance_tenancy"></a> [vpc\_instance\_tenancy](#input\_vpc\_instance\_tenancy) | The tenancy of instances launched into the VPC | `string` | `"default"` | no |
| <a name="input_vpc_name_prefix"></a> [vpc\_name\_prefix](#input\_vpc\_name\_prefix) | The name to use for the VPC | `string` | `"my-vpc"` | no |
| <a name="input_zarf_version"></a> [zarf\_version](#input\_zarf\_version) | The version of Zarf to use | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_instance_id"></a> [bastion\_instance\_id](#output\_bastion\_instance\_id) | The ID of the bastion host |
| <a name="output_bastion_private_key"></a> [bastion\_private\_key](#output\_bastion\_private\_key) | The private key for the bastion host |
| <a name="output_dynamodb_name"></a> [dynamodb\_name](#output\_dynamodb\_name) | Name of DynmoDB table |
| <a name="output_keycloak_db_instance_endpoint"></a> [keycloak\_db\_instance\_endpoint](#output\_keycloak\_db\_instance\_endpoint) | The connection endpoint |
| <a name="output_keycloak_db_instance_name"></a> [keycloak\_db\_instance\_name](#output\_keycloak\_db\_instance\_name) | The database name |
| <a name="output_keycloak_db_instance_port"></a> [keycloak\_db\_instance\_port](#output\_keycloak\_db\_instance\_port) | The database port |
| <a name="output_keycloak_db_instance_username"></a> [keycloak\_db\_instance\_username](#output\_keycloak\_db\_instance\_username) | The master username for the database |
| <a name="output_loki_s3_bucket"></a> [loki\_s3\_bucket](#output\_loki\_s3\_bucket) | Loki S3 Bucket Name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
