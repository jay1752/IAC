variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "expiration_days" {
  description = "Number of days after which objects will be expired"
  type        = number
  default     = 90
} 