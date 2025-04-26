# Environment-specific variables
environment = "dev"  # Development environment identifier
aws_account_id = "975049892546"  # AWS account ID for billing and resource ownership
key_name = "dev-key"  # Name of the SSH key pair for EC2 instance access
bucket_name = "s3-app-bucket"  # S3 bucket name for application data storage
cloudtrail_bucket_name = "dev-cloudtrail-logs-2025"  # S3 bucket for storing AWS CloudTrail logs
cloudwatch_bucket_name = "dev-cloudwatch-logs-2025"  # S3 bucket for storing CloudWatch logs

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
instance_type = "t2.micro"  # EC2 instance type (1 vCPU, 1GB RAM)

# RDS Database Configuration
db_instance_class = "db.t3.micro"  # RDS instance type for database
db_allocated_storage = 20  # Storage size in GB for RDS instance
db_username = "admin"  # Master username for RDS database
db_name = "appdb"  # Name of the application database

# Logging and Retention Settings
expiration_days = 90  # Number of days before S3 objects expire
log_retention_days = 30  # Number of days to retain CloudWatch logs

# SSH Key Configuration
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDdLAhDrb4jiFcuTXGfLgJTGdsb4IJMprhynZYzQpW96/WyrLObX4Yamf+mxkG0UtatKQnwvtP85Cg1IN/5hd0Dki0rwuBLhpQBWohQUNBwFQralSRvtOG/s/ZXJuBN0BAusiehnWFVeW3+gNqm1xUG8owcE3q6FGnANQ+Hy/wvGPU2JDOCH/sl3psHbTuZMb9SACmYQSY3mhHUzEQu5PW3NzinGnaKPSw6ws6+tiqL8dm7PlEnf9uW9dd27xn2RzTg33SsQYStGBVC6NuNx0B7mUNbb6ak8aAp7ftdoCeSxk6hu0VlUKoLds+CPY9OVX+PK7O6REqTdCF3sL/u5siZ jaydeepsarraf@Jaydeeps-MacBook-Air.local"  # Public SSH key for EC2 instance access