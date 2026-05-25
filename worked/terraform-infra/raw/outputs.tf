output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.main.dns_name
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "db_endpoint" {
  description = "The connection endpoint of the RDS instance"
  value       = aws_db_instance.postgres.endpoint
  sensitive   = true
}

output "app_bucket" {
  description = "The name of the application S3 bucket"
  value       = aws_s3_bucket.app.bucket
}

output "sns_topic_arn" {
  description = "The ARN of the SNS alert topic"
  value       = aws_sns_topic.alerts.arn
}
