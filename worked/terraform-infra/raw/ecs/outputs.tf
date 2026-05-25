output "ecs_cluster_names" {
  description = "ECS cluster names"
  value = {
    for env, cluster in aws_ecs_cluster.main : env => cluster.name
  }
}

output "ecs_cluster_arns" {
  description = "ECS cluster ARNs"
  value = {
    for env, cluster in aws_ecs_cluster.main : env => cluster.arn
  }
}

output "ecs_service_names" {
  description = "ECS service names"
  value = {
    for env, service in aws_ecs_service.api : env => service.name
  }
}

output "ecs_task_definition_arns" {
  description = "ECS task definition ARNs"
  value = {
    for env, task_def in aws_ecs_task_definition.api : env => task_def.arn
  }
}

output "cloudwatch_log_groups" {
  description = "CloudWatch log group names"
  value = {
    for env, log_group in aws_cloudwatch_log_group.ecs : env => log_group.name
  }
}

output "ecs_task_execution_role_arns" {
  description = "ECS task execution role ARNs"
  value = {
    for env, role in aws_iam_role.ecs_task_execution : env => role.arn
  }
}

output "ecs_task_role_arns" {
  description = "ECS task role ARNs"
  value = {
    for env, role in aws_iam_role.ecs_task : env => role.arn
  }
}
