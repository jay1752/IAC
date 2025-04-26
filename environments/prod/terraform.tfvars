# Environment-specific variables
environment = "prod"  # Production environment identifier
aws_account_id = "YOUR_AWS_ACCOUNT_ID"  # AWS account ID for billing and resource ownership
key_name = "prod-key"  # Name of the SSH key pair for EC2 instance access
bucket_name = "s3-app-bucket"  # S3 bucket name for application data storage
cloudtrail_bucket_name = "prod-cloudtrail-logs-2025"  # S3 bucket for storing AWS CloudTrail logs
cloudwatch_bucket_name = "prod-cloudwatch-logs-2025"  # S3 bucket for storing CloudWatch logs

# Network Configuration
aws_region = "us-west-2"  # AWS region where resources will be deployed
vpc_cidr = "10.0.0.0/16"  # CIDR block for the VPC (Virtual Private Cloud)
public_subnet_cidr = "10.0.1.0/24"  # CIDR block for public subnet (internet-facing)
private_subnet_cidr = "10.0.2.0/24"  # CIDR block for first private subnet (internal resources)
private_subnet_cidr_2 = "10.0.3.0/24"  # CIDR block for second private subnet (high availability)
availability_zone = "us-west-2a"  # Primary availability zone for resource deployment
availability_zone_2 = "us-west-2b"  # Secondary availability zone for high availability

# EC2 Instance Configuration
ami_id = "ami-010fc6854b20fbff7"  # Amazon Machine Image ID for EC2 instances (Amazon Linux 2)
instance_type = "t2.medium"  # EC2 instance type (2 vCPU, 4GB RAM) for production workload

# RDS Database Configuration
db_instance_class = "db.t3.small"  # RDS instance type for production database
db_allocated_storage = 50  # Storage size in GB for RDS instance
db_username = "admin"  # Master username for RDS database
db_name = "appdb"  # Name of the application database

# Logging and Retention Settings
expiration_days = 90  # Number of days before S3 objects expire
log_retention_days = 30  # Number of days to retain CloudWatch logs

# SSH Key Configuration
ssh_public_key = "YOUR_PRODUCTION_SSH_PUBLIC_KEY"  # Public SSH key for EC2 instance access

