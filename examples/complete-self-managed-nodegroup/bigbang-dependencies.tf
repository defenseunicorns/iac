
###########################################################
############## Big Bang Core Dependencies #################
###########################################################

###########################################################
################# Enable EKS Sops #########################

module "flux_sops" {
  # source = "git::https://github.com/defenseunicorns/iac.git//modules/sops?ref=v<insert tagged version>"
  source = "../../modules/sops"

  region                     = var.region
  cluster_name               = module.eks.eks_cluster_id
  vpc_id                     = module.vpc.vpc_id
  policy_name_prefix         = "${module.eks.eks_cluster_id}-flux-sops"
  kms_key_alias              = "${module.eks.eks_cluster_id}-flux-sops"
  kubernetes_service_account = "flux-system-sops-sa"
  kubernetes_namespace       = "flux-system"
  irsa_sops_iam_role_name    = "${module.eks.eks_cluster_id}-flux-system-sa-role"
  eks_oidc_provider_arn      = module.eks.eks_oidc_provider_arn
  tags                       = local.tags
  role_name                  = module.bastion.bastion_role_name
}

###########################################################
################## Loki S3 Buckets ########################

module "loki_s3_bucket" {
  # source = "git::https://github.com/defenseunicorns/iac.git//modules/s3-irsa?ref=v<insert tagged version>"
  source = "../../modules/s3-irsa"

  region                     = var.region
  cluster_name               = module.eks.eks_cluster_id
  policy_name_prefix         = "loki-s3-policy"
  bucket_prefix              = "loki-s3"
  kms_key_alias              = "loki-s3"
  kubernetes_service_account = "logging-loki-s3-sa"
  kubernetes_namespace       = "logging"
  irsa_iam_role_name         = "${module.eks.eks_cluster_id}-logging-loki-sa-role"
  eks_oidc_provider_arn      = module.eks.eks_oidc_provider_arn
  tags                       = local.tags
  dynamodb_enabled           = true
}

###########################################################
############ Big Bang Add-Ons Dependencies ################
###########################################################

###########################################################
############### Keycloak RDS Database #####################

module "rds_postgres_keycloak" {
  # source = "git::https://github.com/defenseunicorns/iac.git//modules/rds?ref=v<insert tagged version>"
  source = "../../modules/rds"

  count = var.keycloak_enabled ? 1 : 0

  # provider alias is needed for every parent module supporting RDS backup replication is a separate region
  providers = {
    aws.region2 = aws.region2
  }

  vpc_id                     = module.vpc.vpc_id
  vpc_cidr                   = module.vpc.vpc_cidr_block
  database_subnet_group_name = module.vpc.database_subnet_group_name
  engine                     = "postgres"
  engine_version             = var.kc_db_engine_version
  family                     = var.kc_db_family
  major_engine_version       = var.kc_db_major_engine_version
  instance_class             = var.kc_db_instance_class
  identifier                 = "${var.cluster_name}-keycloak"
  db_name                    = "keycloak" # Can only be alphanumeric, no hyphens or underscores
  username                   = "kcadmin"
  create_random_password     = false
  password                   = var.keycloak_db_password
  allocated_storage          = var.kc_db_allocated_storage
  max_allocated_storage      = var.kc_db_max_allocated_storage
  create_db_subnet_group     = true
  deletion_protection        = var.rds_deletion_protection
  # automated_backups_replication_enabled = true
  tags = local.tags
}
