variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name used for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID from VPC module output"
  type        = string
}

# From Step 1: VPC
variable "private_db_subnet_ids" {
  description = "Private DB subnet IDs from VPC module output"
  type        = map(string)
}

# From Step 2: Security Groups
variable "rds_security_group_ids" {
  description = "RDS security group IDs from security-groups module output"
  type        = map(string)
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "postgres"
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "mydb"
}

variable "db_password_dev" {
  type      = string
  sensitive = true
}

variable "db_password_staging" {
  type      = string
  sensitive = true
}

variable "db_password_prod" {
  type      = string
  sensitive = true
}
