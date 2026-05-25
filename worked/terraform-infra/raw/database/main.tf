# Secrets Manager for passwords (using passwords from .env initially)
resource "aws_secretsmanager_secret" "db_password" {
  for_each = toset(["dev", "staging", "prod"])
  
  name                    = "${var.project}-${each.key}-db-password-v2"
  recovery_window_in_days = 0
  
  tags = {
    Name        = "${var.project}-${each.key}-db-password"
    Environment = each.key
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  for_each = toset(["dev", "staging", "prod"])
  
  secret_id = aws_secretsmanager_secret.db_password[each.key].id
  secret_string = each.key == "dev" ? var.db_password_dev : (
    each.key == "staging" ? var.db_password_staging : var.db_password_prod
  )
}

# DB Subnet Groups
# Note: For Multi-AZ RDS (production), you need subnets in multiple AZs
# Currently each environment uses a single subnet. For production Multi-AZ,
# consider using multiple subnets from different AZs.
resource "aws_db_subnet_group" "main" {
  for_each = toset(["dev", "staging", "prod"])
  
  name       = "${var.project}-${each.key}-db-subnet-group"
  # Use the subnet for this specific environment
  # For Multi-AZ, you'd want: [var.private_db_subnet_ids[each.key], var.private_db_subnet_ids_secondary[each.key]]
  subnet_ids = [var.private_db_subnet_ids[each.key]]
  
  tags = {
    Name        = "${var.project}-${each.key}-db-subnet-group"
    Environment = each.key
  }
}

# RDS PostgreSQL for Dev
resource "aws_db_instance" "dev" {
  identifier     = "${var.project}-dev-postgres"
  engine         = "postgres"
  engine_version = "17.5"
  instance_class = "db.t3.medium"
  
  allocated_storage     = 20
  max_allocated_storage = 40
  storage_type          = "gp3"
  storage_encrypted     = true
  
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password_dev
  port     = 5432
  
  db_subnet_group_name   = aws_db_subnet_group.main["dev"].name
  vpc_security_group_ids = [var.rds_security_group_ids["dev"]]
  
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"
  
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  performance_insights_enabled    = true
  performance_insights_retention_period = 7
  
  skip_final_snapshot       = true
  final_snapshot_identifier = "${var.project}-dev-final-snapshot"
  
  tags = {
    Name        = "${var.project}-dev-postgres"
    Environment = "dev"
  }
}

# RDS PostgreSQL for Staging
resource "aws_db_instance" "staging" {
  identifier     = "${var.project}-staging-postgres"
  engine         = "postgres"
  engine_version = "17.5"
  instance_class = "db.t3.large"
  
  allocated_storage     = 50
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true
  
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password_staging
  port     = 5432
  
  db_subnet_group_name   = aws_db_subnet_group.main["staging"].name
  vpc_security_group_ids = [var.rds_security_group_ids["staging"]]
  
  backup_retention_period = 14
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"
  
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  performance_insights_enabled    = true
  performance_insights_retention_period = 7
  
  skip_final_snapshot       = true
  final_snapshot_identifier = "${var.project}-staging-final-snapshot"
  
  tags = {
    Name        = "${var.project}-staging-postgres"
    Environment = "staging"
  }
}

# RDS PostgreSQL for Production (Highly Scalable)
resource "aws_db_instance" "prod" {
  identifier     = "${var.project}-prod-postgres"
  engine         = "postgres"
  engine_version = "17.5"
  instance_class = "db.r6g.2xlarge"  # Larger instance for high performance
  
  allocated_storage     = 100  # Start with 100 GB
  max_allocated_storage = 1000 # Auto-scale up to 1 TB as needed
  storage_type          = "gp3"
  storage_encrypted     = true
  # No need for provisioned IOPS yet - gp3 baseline is 3000 IOPS (enough for most workloads)
  
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password_prod
  port     = 5432
  
  db_subnet_group_name   = aws_db_subnet_group.main["prod"].name
  vpc_security_group_ids = [var.rds_security_group_ids["prod"]]
  
  # High availability with Multi-AZ
  multi_az = true
  
  # Backups
  backup_retention_period      = 35
  backup_window                = "03:00-04:00"
  maintenance_window           = "mon:04:00-mon:05:00"
  delete_automated_backups     = false
  
  # Performance and monitoring
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  enabled_cloudwatch_logs_exports       = ["postgresql", "upgrade"]
  monitoring_interval                   = 60
  monitoring_role_arn                   = aws_iam_role.rds_monitoring.arn
  
  # Read replicas can be added later for scaling reads
  # Supports up to 15 read replicas
  
  # Auto minor version upgrade
  auto_minor_version_upgrade = true
  
  # Deletion protection for production
  deletion_protection = true
  
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.project}-prod-postgres-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
  tags = {
    Name        = "${var.project}-prod-postgres"
    Environment = "prod"
  }
}

# IAM Role for Enhanced Monitoring
resource "aws_iam_role" "rds_monitoring" {
  name = "${var.project}-rds-enhanced-monitoring"

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
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
