# AWS Infrastructure Setup with Terraform

This repository contains Terraform modules to set up a development environment in AWS.

## Prerequisites

1. AWS CLI installed and configured
2. Terraform installed (version >= 1.0.0)
3. AWS account ID

## Infrastructure Components

### 1. Networking Module (`modules/networking/`)
- VPC Configuration:
  - CIDR: 10.0.0.0/16
  - Public Subnet: 10.0.1.0/24
  - Private Subnet: 10.0.2.0/24
- Security Groups:
  - EC2: SSH (22), HTTP (80), HTTPS (443)
  - RDS: MySQL (3306) from EC2
- Internet Gateway
- Route Tables for public and private subnets

### 2. Compute Module (`modules/compute/`)
- EC2 Instance:
  - Dev: t2.micro, 20GB storage
  - Prod: t2.small, 50GB storage
  - Amazon Linux 2 AMI
  - User data script for initialization
- IAM Role:
  - CloudWatch Logs access
  - S3 bucket access
  - Secrets Manager access
- Key Pair for SSH access
- CloudWatch agent role

### 3. Database Module (`modules/database/`)
- RDS MySQL:
  - Dev: db.t3.micro, 20GB
  - Prod: db.t3.small, 50GB
  - Multi-AZ: No (dev), Yes (prod)
  - Backup retention: 7 days
  - Encryption enabled
- Parameter Group
- Subnet Group
- Security Group
- RDS monitoring role
- RDS credentials
- KMS encryption keys

### 4. Storage Module (`modules/storage/`)
- S3 Bucket:
  - Versioning enabled
  - Server-side encryption (AES-256)
  - Lifecycle rules (90 days)
  - Public access blocked
- Bucket Policy:
  - CloudTrail access
  - EC2 instance access
- S3 server-side encryption

### 5. Monitoring Module (`modules/monitoring/`)
- CloudWatch Agent:
  - System metrics collection (60s interval)
  - Log collection
- Log Groups:
  - `/ec2/bootstrap`: Bootstrap script logs
  - `/ec2/cloudwatch-agent`: Agent logs
  - `/ec2/app`: Application logs
- Metrics:
  - CPU: idle, user, system usage
  - Memory: used, available, total
  - Disk: used, free, total
  - Swap: used, free, total
- CloudTrail setup

## Environment Configuration

### Development Environment
- Region: us-west-2
- Instance Type: t2.micro
- Database: db.t3.micro
- Storage: 20GB
- Single AZ deployment
- Development settings

### Production Environment
- Region: us-west-2
- Instance Type: t2.small
- Database: db.t3.small
- Storage: 50GB
- Multi-AZ deployment
- Production settings

## Getting Started

1. Create IAM User and Policy:(one time setup)
   - Login as root user into aws account
   - Go to AWS Console > IAM > Users > Create user
   - Enter username: "terraform-user"
   - Select "Add user to group"
   - Click "Next and then create user"
   - Select users: "terraform-user"
   - Select Permissions and Click "Add permissions"
   - Select "Create inline policy"
   - Choose JSON editor and paste the following policy:
     ```json
     {
         "Version": "2012-10-17",
         "Statement": [
             {
                 "Effect": "Allow",
                 "Action": [
                     "ec2:*",
                     "rds:*",
                     "s3:*",
                     "iam:*",
                     "cloudwatch:*",
                     "cloudtrail:*",
                     "kms:*",
                     "events:*",
                     "ssm:*",
                     "secretsmanager:*",
                     "dynamodb:*",
                     "logs:*",
                     "sns:*",
                     "tag:*"
                 ],
                 "Resource": "*"
             }
         ]
     }
     ```
   - Name the policy: "TerraformFullAccessCustom"
   - Add description: "Custom policy for Terraform to manage infrastructure"
   - Click "Create policy"
   - Go back to user
   - Select "Security credentials" 
   - Click on "create access key"
   - Select "Local code" and "tick mark" confirmation and Select next
   - Provide "Description tag value: terraform access key"
   - Copy "Access key and Secret access key" and save/Download .csv file
   - Done

2. Set up AWS Environments:
   - Set up AWS profiles for different environments:
     ```bash
     # For dev environment
     aws configure --profile dev
     # Enter dev environment credentials
     # Enter your AWS Access Key ID
     # Enter your AWS Secret Access Key
     # Enter your default region (e.g., us-west-2) : user access key region
     # Enter your output format (json)
     
     # For prod environment
     aws configure --profile prod
     # Enter production environment credentials
     # Enter your AWS Access Key ID
     # Enter your AWS Secret Access Key
     # Enter your default region (e.g., us-west-2) :user access key region
     # Enter your output format (json)
     ```
   - Set environment variables for Terraform:
     ```bash
     # For dev environment
     export AWS_PROFILE=dev
     
     # For prod environment
     export AWS_PROFILE=prod
     ```

   - Verify environment profiles:
     ```bash
     aws sts get-caller-identity --profile dev
     aws sts get-caller-identity --profile prod
     ```

3. SSH Key Pair Management:(one time setup)
   - Create SSH key pairs locally for each environment:
     ```bash
     # For dev environment
     ssh-keygen -t rsa -b 2048 -f environments/dev/dev-key -N ""
     chmod 400 environments/dev/dev-key
     
     # For prod environment
     ssh-keygen -t rsa -b 2048 -f environments/dev/dev-key -N ""
     chmod 400 environments/prod/prod-key
     ```
   - Copy the public key content from the .pub file:
     ```bash
     # For dev environment
     cat environments/dev/dev-key.pub
     
     # For prod environment
     cat environments/prod/prod-key.pub
     ```
   - Add the public key content to your environment's `terraform.tfvars` file:
     ```hcl
     # For dev environment (environments/dev/terraform.tfvars)
     ssh_public_key = "ssh-rsa AAAA... your-dev-public-key-content ..."
     
     # For prod environment (environments/prod/terraform.tfvars)
     ssh_public_key = "ssh-rsa AAAA... your-prod-public-key-content ..."
     ```
   - The private keys are stored in the following locations:
     - Dev: `environments/dev/dev-key`
     - Prod: `environments/prod/prod-key`
   - Keep these private keys secure and never commit them to version control

4. Set up the Terraform backend:(one time setup)
   - Create an S3 bucket for Terraform state:
     ```bash
     aws s3api create-bucket \
       --bucket terraform-state-iac-dev-2025 \
       --region us-west-1 \
       --create-bucket-configuration LocationConstraint=us-west-1
     ```
   - Enable versioning on the bucket:
     ```bash
     aws s3api put-bucket-versioning \
       --bucket terraform-state-iac-dev-2025 \
       --versioning-configuration Status=Enabled
     ```
   - Create a DynamoDB table for state locking:
     ```bash
     aws dynamodb create-table \
       --table-name terraform-state-lock \
       --attribute-definitions AttributeName=LockID,AttributeType=S \
       --key-schema AttributeName=LockID,KeyType=HASH \
       --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
       --region us-east-1
     ```

5. Configure Environment Variables:
   - All variables are defined in the root `variables.tf` file
   - Set environment-specific values in the respective `terraform.tfvars` files:
     ```hcl
     # environments/dev/terraform.tfvars
     environment = "dev"
     aws_account_id = "YOUR_AWS_ACCOUNT_ID"
     key_name = "dev-key"
     bucket_name = "dev-app-bucket"
     aws_region = "us-west-2"
     vpc_cidr = "10.0.0.0/16"
     public_subnet_cidr = "10.0.1.0/24"
     private_subnet_cidr = "10.0.2.0/24"
     availability_zone = "us-west-2a"
     ami_id = "ami-0c55b159cbfafe1f0"
     instance_type = "t2.micro"
     db_instance_class = "db.t3.micro"
     db_allocated_storage = 20
     db_username = "admin"
     db_name = "appdb"
     expiration_days = 90
     log_retention_days = 30
     ssh_public_key = "ssh-rsa AAAA... your-public-key-content ..."
     ```

   - For production, create a similar file at `environments/prod/terraform.tfvars` with appropriate values

6. Initialize Terraform:
```bash
terraform init
```

7. Plan the changes:
```bash
# For dev environment
terraform plan -var-file=environments/dev/terraform.tfvars

# For prod environment
terraform plan -var-file=environments/prod/terraform.tfvars
```

8. Apply the changes:
```bash
# For dev environment
terraform apply -var-file=environments/dev/terraform.tfvars

# For prod environment
terraform apply -var-file=environments/prod/terraform.tfvars
```

## Accessing Resources

### EC2 Instance
After applying the Terraform configuration, you can SSH into the EC2 instance:
```bash
ssh -i dev-key.pem ec2-user@<ec2_public_ip>
```

### RDS Database
The RDS endpoint and credentials will be available in AWS Secrets Manager. You can retrieve them using:
```bash
aws secretsmanager get-secret-value --secret-id dev-rds-credentials --region us-west-2
```
To connect to the MySQL database from ec2:

```bash
mysql -h <rds_endpoint> -u admin -p
```



### S3 Bucket
The S3 bucket name and ARN will be available in the Terraform outputs.

## Monitoring

- CloudWatch Dashboard URL: Available in Terraform outputs
- CloudTrail logs: Stored in the S3 bucket
- CloudWatch Logs: Available for EC2 and RDS instances

## Security

- All credentials are stored in AWS Secrets Manager
- RDS is in a private subnet
- S3 bucket has public access blocked
- IAM roles follow the principle of least privilege
- SSH access is restricted to the specified key pair
- Terraform state is stored in an encrypted S3 bucket
- State locking is enabled using DynamoDB

## Cleanup

To destroy all resources:
```bash
# For dev environment
terraform destroy -var-file=environments/dev/terraform.tfvars

# For prod environment
terraform destroy -var-file=environments/prod/terraform.tfvars
```

## Module Structure

- `modules/networking`: VPC, subnets, security groups
- `modules/compute`: EC2 instance, IAM roles
- `modules/database`: RDS instance, parameter groups
- `modules/storage`: S3 bucket, lifecycle rules
- `modules/monitoring`: CloudWatch, CloudTrail setup

## Outputs

After applying the configuration, the following outputs will be available:
- VPC ID
- Public and private subnet IDs
- EC2 instance ID and public IP
- RDS endpoint and secret ARN
- S3 bucket ID and ARN
- CloudWatch dashboard URL
- CloudTrail trail name 