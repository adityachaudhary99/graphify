resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = aws_subnet.database[*].id

  tags = {
    Environment = var.environment
  }
}

resource "aws_db_parameter_group" "postgres" {
  name        = "${var.environment}-postgres-pg"
  family      = "postgres16"
  description = "Custom parameter group for ${var.environment}"

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  parameter {
    name  = "random_page_cost"
    value = "1.1"
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_db_instance" "postgres" {
  identifier             = "${var.environment}-postgres"
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = var.db_instance_class
  allocated_storage      = 100
  storage_type           = "gp3"
  storage_encrypted      = true
  db_name                = "appdb"
  username               = "appuser"
  password               = random_password.db_master.result
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]
  parameter_group_name   = aws_db_parameter_group.postgres.name
  backup_retention_period = 30
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:05:00-sun:06:00"
  multi_az               = true
  skip_final_snapshot    = var.environment != "production"
  deletion_protection    = var.environment == "production"

  tags = {
    Environment = var.environment
  }
}

resource "random_password" "db_master" {
  length  = 24
  special = false
}
