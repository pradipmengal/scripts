output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_secret_arn" {
  description = "Secrets Manager ARN"
  value       = aws_secretsmanager_secret.rds.arn
}

output "private_subnets_used" {
  description = "Private subnets from remote state"
  value       = local.private_subnet_ids
}
