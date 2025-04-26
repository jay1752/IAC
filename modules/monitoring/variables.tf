variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "ec2_instance_id" {
  description = "ID of the EC2 instance to monitor"
  type        = string
}

variable "rds_instance_id" {
  description = "ID of the RDS instance to monitor"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "cloudtrail_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  type        = string
} 