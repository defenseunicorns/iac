output "loki_s3_bucket" {
  description = "Loki S3 Bucket Name"
  value       = module.loki_s3_bucket.s3_bucket
}

output "keycloak_db_instance_endpoint" {
  description = "The connection endpoint"
  value       = module.rds_postgres_keycloak[0].db_instance_endpoint
}

output "keycloak_db_instance_name" {
  description = "The database name"
  value       = module.rds_postgres_keycloak[0].db_instance_name
}

output "keycloak_db_instance_username" {
  description = "The master username for the database"
  value       = module.rds_postgres_keycloak[0].db_instance_username
  sensitive   = true
}

output "keycloak_db_instance_port" {
  description = "The database port"
  value       = module.rds_postgres_keycloak[0].db_instance_port
}

output "bastion_instance_id" {
  description = "The ID of the bastion host"
  value       = module.bastion.instance_id
}

output "bastion_private_key" {
  description = "The private key for the bastion host"
  value       = module.bastion.private_key
  sensitive   = true
}
output "dynamodb_name" {
  description = "Name of DynmoDB table"
  value       = module.loki_s3_bucket.dynamodb_name
}
