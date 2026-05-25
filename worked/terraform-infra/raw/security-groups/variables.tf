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
  description = "VPC ID from step 1"
  type        = string
  default     = "vpc-0fe52e3eb5428413a"
}

variable "environments" {
  description = "Environments"
  type        = list(string)
  default     = ["dev", "staging", "prod"]
}
