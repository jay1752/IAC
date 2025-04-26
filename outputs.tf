# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = module.networking.public_subnet_id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = module.networking.private_subnet_id
}

# EC2 Outputs
output "ec2_instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.compute.instance_id
}

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = module.compute.instance_public_ip
}

# RDS Outputs
output "rds_endpoint" {
  description = "The connection endpoint of the RDS instance"
  value       = module.database.db_endpoint
}

output "rds_instance_id" {
  description = "The ID of the RDS instance"
  value       = module.database.db_instance_id
}

output "rds_secret_arn" {
  description = "The ARN of the Secrets Manager secret containing database credentials"
  value       = module.database.db_secret_arn
}

# S3 Outputs
output "s3_bucket_id" {
  description = "The ID of the S3 bucket"
  value       = module.storage.bucket_id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = module.storage.bucket_arn
}

# Monitoring Outputs
output "cloudwatch_dashboard_url" {
  description = "The URL of the CloudWatch dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${var.environment}-dashboard"
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic for alerts"
  value       = module.monitoring.sns_topic_arn
}

output "cloudtrail_trail_name" {
  description = "The name of the CloudTrail trail"
  value       = module.monitoring.cloudtrail_name
}
