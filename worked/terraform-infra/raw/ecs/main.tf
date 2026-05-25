# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "ecs" {
  for_each = toset(["dev", "staging", "prod"])
  
  name              = "/ecs/${var.project}-${each.key}"
  retention_in_days = each.key == "prod" ? 30 : 7
  
  tags = {
    Name        = "${var.project}-${each.key}-logs"
    Environment = each.key
  }
}

# ECS Clusters
resource "aws_ecs_cluster" "main" {
  for_each = toset(["dev", "staging", "prod"])
  
  name = "${var.project}-${each.key}-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  
  tags = {
    Name        = "${var.project}-${each.key}-cluster"
    Environment = each.key
  }
}

# ECS Cluster Capacity Providers
resource "aws_ecs_cluster_capacity_providers" "main" {
  for_each = toset(["dev", "staging", "prod"])
  
  cluster_name = aws_ecs_cluster.main[each.key].name
  
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  
  default_capacity_provider_strategy {
    capacity_provider = each.key == "prod" ? "FARGATE" : "FARGATE_SPOT"
    weight            = 1
    base              = 1
  }
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution" {
  for_each = toset(["dev", "staging", "prod"])
  
  name = "${var.project}-${each.key}-ecs-task-execution"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  
  tags = {
    Name        = "${var.project}-${each.key}-ecs-task-execution"
    Environment = each.key
  }
}

# Attach AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  for_each = toset(["dev", "staging", "prod"])
  
  role       = aws_iam_role.ecs_task_execution[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM Policy for Secrets Manager access
resource "aws_iam_role_policy" "ecs_secrets" {
  for_each = toset(["dev", "staging", "prod"])
  
  name = "${var.project}-${each.key}-ecs-secrets"
  role = aws_iam_role.ecs_task_execution[each.key].id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.db_secret_arns[each.key]
      }
    ]
  })
}

# IAM Role for ECS Task (application role)
resource "aws_iam_role" "ecs_task" {
  for_each = toset(["dev", "staging", "prod"])
  
  name = "${var.project}-${each.key}-ecs-task"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  
  tags = {
    Name        = "${var.project}-${each.key}-ecs-task"
    Environment = each.key
  }
}

# ECS Task Definitions
resource "aws_ecs_task_definition" "api" {
  for_each = toset(["dev", "staging", "prod"])
  
  family                   = "${var.project}-${each.key}-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.key == "prod" ? "1024" : "512"
  memory                   = each.key == "prod" ? "2048" : "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution[each.key].arn
  task_role_arn            = aws_iam_role.ecs_task[each.key].arn
  
  container_definitions = jsonencode([
    {
      name  = "api"
      image = "${var.ecr_repository_url}:${each.key}-latest"
      
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      
      environment = [
        {
          name  = "ENVIRONMENT"
          value = each.key
        },
        {
          name  = "DB_HOST"
          value = split(":", var.database_endpoints[each.key].endpoint)[0]
        },
        {
          name  = "DB_PORT"
          value = tostring(var.database_endpoints[each.key].port)
        },
        {
          name  = "DB_NAME"
          value = var.database_endpoints[each.key].database
        },
        {
          name  = "DB_USER"
          value = "postgres"
        }
      ]
      
      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = var.db_secret_arns[each.key]
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs[each.key].name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "api"
        }
      }
      
      healthCheck = {
        command     = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])
  
  tags = {
    Name        = "${var.project}-${each.key}-api"
    Environment = each.key
  }
}

# ECS Services
resource "aws_ecs_service" "api" {
  for_each = toset(["dev", "staging", "prod"])
  
  name            = "${var.project}-${each.key}-api-service"
  cluster         = aws_ecs_cluster.main[each.key].id
  task_definition = aws_ecs_task_definition.api[each.key].arn
  desired_count   = each.key == "prod" ? 2 : 1
  
  # Use capacity provider strategy instead of launch_type
  capacity_provider_strategy {
    capacity_provider = each.key == "prod" ? "FARGATE" : "FARGATE_SPOT"
    weight            = 1
    base              = 1
  }
  
  network_configuration {
    subnets          = [var.private_app_subnet_ids[each.key]]
    security_groups  = [var.ecs_security_group_ids[each.key]]
    assign_public_ip = false
  }
  
  load_balancer {
    target_group_arn = var.alb_target_group_arns[each.key]
    container_name   = "api"
    container_port   = 80
  }
  
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  enable_execute_command = true
  
  tags = {
    Name        = "${var.project}-${each.key}-api-service"
    Environment = each.key
  }
  
  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution]
}

# Auto Scaling Target
resource "aws_appautoscaling_target" "ecs" {
  for_each = toset(["dev", "staging", "prod"])
  
  max_capacity       = each.key == "prod" ? 10 : 4
  min_capacity       = each.key == "prod" ? 2 : 1
  resource_id        = "service/${aws_ecs_cluster.main[each.key].name}/${aws_ecs_service.api[each.key].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Auto Scaling Policy - CPU
resource "aws_appautoscaling_policy" "ecs_cpu" {
  for_each = toset(["dev", "staging", "prod"])
  
  name               = "${var.project}-${each.key}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs[each.key].service_namespace
  
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# Auto Scaling Policy - Memory
resource "aws_appautoscaling_policy" "ecs_memory" {
  for_each = toset(["dev", "staging", "prod"])
  
  name               = "${var.project}-${each.key}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs[each.key].service_namespace
  
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = 80.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}
