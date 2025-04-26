output "db_instance_id" {
  description = "The ID of the RDS instance"
  value       = aws_db_instance.mysql.id
}

output "db_endpoint" {
  description = "The connection endpoint of the RDS instance"
  value       = aws_db_instance.mysql.endpoint
}

output "db_name" {
  description = "The name of the database"
  value       = aws_db_instance.mysql.db_name
}

output "db_username" {
  description = "The master username for the database"
  value       = aws_db_instance.mysql.username
}

output "db_secret_arn" {
  description = "The ARN of the Secrets Manager secret containing database credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
} 