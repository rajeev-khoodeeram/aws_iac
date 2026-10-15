
output "db_identifier" {
  description = "RDS database identifier"
  value       = aws_db_instance.retail.identifier
}

output "db_endpoint" {
  description = "Private PostgreSQL endpoint"
  value       = aws_db_instance.retail.address
}

output "db_port" {
  description = "PostgreSQL port"
  value       = aws_db_instance.retail.port
}

output "db_name" {
  description = "Initial database name"
  value       = aws_db_instance.retail.db_name
}

output "db_security_group_id" {
  description = "Security group protecting PostgreSQL"
  value       = aws_security_group.postgres.id
}

output "master_secret_arn" {
  description = "Secrets Manager ARN for the RDS-managed master credentials"
  value       = aws_db_instance.retail.master_user_secret[0].secret_arn
}
