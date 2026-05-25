# ALB Security Groups (per environment)
resource "aws_security_group" "alb" {
  for_each = toset(var.environments)
  
  name        = "${var.project}-${each.key}-alb-sg"
  description = "Security group for ${each.key} ALB"
  vpc_id      = var.vpc_id
  
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "${var.project}-${each.key}-alb-sg"
    Environment = each.key
  }
}

# ECS Tasks Security Groups (per environment)
resource "aws_security_group" "ecs_tasks" {
  for_each = toset(var.environments)
  
  name        = "${var.project}-${each.key}-ecs-tasks-sg"
  description = "Security group for ${each.key} ECS tasks"
  vpc_id      = var.vpc_id
  
  ingress {
    description     = "Traffic from ALB"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb[each.key].id]
  }
  
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "${var.project}-${each.key}-ecs-tasks-sg"
    Environment = each.key
  }
}

# RDS Security Groups (per environment)
resource "aws_security_group" "rds" {
  for_each = toset(var.environments)
  
  name        = "${var.project}-${each.key}-rds-sg"
  description = "Security group for ${each.key} RDS"
  vpc_id      = var.vpc_id
  
  ingress {
    description     = "PostgreSQL from ECS tasks"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks[each.key].id]
  }
  
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "${var.project}-${each.key}-rds-sg"
    Environment = each.key
  }
}
