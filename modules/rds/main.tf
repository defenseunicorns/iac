data "aws_caller_identity" "current" {}

################################################################################
# RDS Module
################################################################################

module "db" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-rds.git?ref=v5.2.3"

  identifier = var.identifier

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = var.engine
  engine_version       = var.engine_version
  family               = var.family               # DB parameter group
  major_engine_version = var.major_engine_version # DB option group
  instance_class       = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name                = var.db_name
  username               = var.username
  create_random_password = var.create_random_password
  password               = var.password # If 'create_random_password' is false, then 'password' must be set
  port                   = 5432

  multi_az               = true
  db_subnet_group_name   = var.database_subnet_group_name
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true

  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = true
  deletion_protection     = var.deletion_protection

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "example-monitoring-role-name"
  monitoring_role_use_name_prefix       = true
  monitoring_role_description           = "Description for monitoring role"

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  tags = var.tags
  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
}

################################################################################
# RDS Automated Backups Replication Module
################################################################################

# needs additional testing for GovCloud

# module "kms" {
#   source      = "terraform-aws-modules/kms/aws"

#   version     = "~> 1.3"
#   description = "KMS key for cross region automated backups replication"

#   # Aliases
#   aliases                 = [var.db_name]
#   aliases_use_name_prefix = true

#   key_owners = [data.aws_caller_identity.current.arn]

#   tags = var.tags

#   providers = {
#     aws = aws.region2
#   }
# }

# module "db_automated_backups_replication" {
#   source = "git::https://github.com/terraform-aws-modules/terraform-aws-rds.git//modules/db_instance_automated_backups_replication?ref=v5.2.3"

#   count = var.automated_backups_replication_enabled != null ? 1 : 0

#   source_db_instance_arn = module.db.db_instance_arn
#   kms_key_arn            = module.kms.key_arn

#   providers = {
#     aws = aws.region2
#   }
# }

################################################################################
# Supporting Resources
################################################################################
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.17"

  name        = var.db_name
  description = "Complete PostgreSQL example security group"
  vpc_id      = var.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = var.vpc_cidr
    },
  ]

  tags = var.tags
}
