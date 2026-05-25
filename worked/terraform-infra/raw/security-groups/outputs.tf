output "alb_security_group_ids" {
  description = "ALB security group IDs"
  value = {
    for env, sg in aws_security_group.alb : env => sg.id
  }
}

output "ecs_tasks_security_group_ids" {
  description = "ECS tasks security group IDs"
  value = {
    for env, sg in aws_security_group.ecs_tasks : env => sg.id
  }
}

output "rds_security_group_ids" {
  description = "RDS security group IDs"
  value = {
    for env, sg in aws_security_group.rds : env => sg.id
  }
}
