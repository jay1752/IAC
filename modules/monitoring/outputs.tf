output "ec2_log_group_name" {
  description = "Name of the CloudWatch log group for EC2"
  value       = aws_cloudwatch_log_group.ec2.name
}

output "rds_log_group_name" {
  description = "Name of the CloudWatch log group for RDS"
  value       = aws_cloudwatch_log_group.rds.name
}

output "alarm_arn" {
  description = "ARN of the CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.ec2_cpu.arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = aws_sns_topic.alerts.arn
}

output "cloudtrail_name" {
  description = "Name of the CloudTrail trail"
  value       = aws_cloudtrail.main.name
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

