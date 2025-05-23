terraform {
  backend "s3" {
    bucket         = "terraform-state-iac-dev-2025"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}