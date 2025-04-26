# Generate random password
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store credentials in Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.environment}-rds-credentials"
  description = "MySQL database credentials"

  tags = {
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    engine   = "mysql"
    port     = 3306
    dbname   = var.db_name
  })
}

# RDS Instance
resource "aws_db_instance" "mysql" {
  identifier           = "${var.environment}-mysql"
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = var.instance_class
  allocated_storage   = var.allocated_storage
  storage_type        = "gp2"
  username            = var.db_username
  password            = random_password.db_password.result
  parameter_group_name = aws_db_parameter_group.mysql.name
  skip_final_snapshot = true
  publicly_accessible = false
  vpc_security_group_ids = [var.security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.mysql.name

  tags = {
    Name        = "${var.environment}-mysql"
    Environment = var.environment
  }
}

# DB Parameter Group
resource "aws_db_parameter_group" "mysql" {
  name   = "${var.environment}-mysql-params"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }

  tags = {
    Environment = var.environment
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "mysql" {
  name       = "${var.environment}-mysql-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name        = "${var.environment}-mysql-subnet-group"
    Environment = var.environment
  }
}

# KMS Key for RDS Encryption
resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Environment = var.environment
  }
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.environment}-rds-key"
  target_key_id = aws_kms_key.rds.key_id
}

# IAM Role for RDS Enhanced Monitoring
resource "aws_iam_role" "rds_monitoring" {
  name = "${var.environment}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# RDS Event Subscription
resource "aws_db_event_subscription" "main" {
  count     = var.sns_topic_arn != null ? 1 : 0
  name      = "${var.environment}-rds-events"
  sns_topic = var.sns_topic_arn

  source_type = "db-instance"
  source_ids  = [aws_db_instance.mysql.id]

  event_categories = [
    "availability",
    "backup",
    "configuration change",
    "deletion",
    "failure",
    "maintenance",
    "notification",
    "read replica",
    "recovery",
    "restoration"
  ]

  tags = {
    Environment = var.environment
  }
} 