variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name used for resource naming"
  type        = string
}

# From VPC outputs
variable "vpc_id" {
  description = "VPC ID from VPC module output"
  type        = string
}

variable "private_app_subnet_ids" {
  description = "Private app subnet IDs from VPC module output"
  type        = map(string)
}

# From Security Groups outputs
variable "ecs_security_group_ids" {
  description = "ECS security group IDs from security-groups module output"
  type        = map(string)
}

# From ALB outputs
variable "alb_target_group_arns" {
  description = "ALB target group ARNs from ALB module output"
  type        = map(string)
}

# From Database outputs
variable "database_endpoints" {
  description = "Database endpoints from database module output"
  type = map(object({
    endpoint       = optional(string)
    writer_endpoint = optional(string)
    reader_endpoint = optional(string)
    database      = string
    port          = number
  }))
}

variable "db_secret_arns" {
  description = "Database secret ARNs from database module output"
  type        = map(string)
}

# From ECR outputs
variable "ecr_repository_url" {
  description = "ECR repository URL from ECR module output"
  type        = string
}
