output "dev_rds_endpoint" {
  description = "Dev RDS endpoint"
  value       = aws_db_instance.dev.endpoint
}

output "staging_rds_endpoint" {
  description = "Staging RDS endpoint"
  value       = aws_db_instance.staging.endpoint
}

output "prod_rds_endpoint" {
  description = "Production RDS endpoint"
  value       = aws_db_instance.prod.endpoint
}

output "database_endpoints" {
  description = "All database endpoints"
  value = {
    dev = {
      endpoint = aws_db_instance.dev.endpoint
      port     = aws_db_instance.dev.port
      database = aws_db_instance.dev.db_name
    }
    staging = {
      endpoint = aws_db_instance.staging.endpoint
      port     = aws_db_instance.staging.port
      database = aws_db_instance.staging.db_name
    }
    prod = {
      endpoint = aws_db_instance.prod.endpoint
      port     = aws_db_instance.prod.port
      database = aws_db_instance.prod.db_name
    }
  }
}

output "db_secret_arns" {
  description = "Secrets Manager ARNs for database passwords"
  value = {
    for env, secret in aws_secretsmanager_secret.db_password : env => secret.arn
  }
  sensitive = true
}
