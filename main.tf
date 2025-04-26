provider "aws" {
  region = var.aws_region
}

# Terraform Configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  environment          = var.environment
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  private_subnet_cidr_2 = var.private_subnet_cidr_2
  availability_zone   = var.availability_zone
  availability_zone_2 = var.availability_zone_2
}

# Compute Module
module "compute" {
  source = "./modules/compute"

  environment        = var.environment
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  subnet_id         = module.networking.public_subnet_id
  security_group_id = module.networking.ec2_security_group_id
  key_name          = var.key_name
  ssh_public_key    = var.ssh_public_key
  aws_region        = var.aws_region
  aws_account_id    = var.aws_account_id
  bucket_name       = "${var.environment}-${var.bucket_name}"

}

# Database Module
module "database" {
  source = "./modules/database"

  environment        = var.environment
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  db_username       = var.db_username
  db_name           = var.db_name
  security_group_id = module.networking.rds_security_group_id
  subnet_ids        = [module.networking.private_subnet_id, module.networking.private_subnet_id_2]
}

# Storage Module
module "storage" {
  source = "./modules/storage"

  environment      = var.environment
  bucket_name     = var.bucket_name
  expiration_days = var.expiration_days
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  environment           = var.environment
  aws_region           = var.aws_region
  log_retention_days   = var.log_retention_days
  ec2_instance_id      = module.compute.instance_id
  rds_instance_id      = module.database.db_instance_id
  cloudtrail_bucket_name = module.storage.bucket_id
} 