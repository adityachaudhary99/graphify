variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name used for resource naming (lowercase, alphanumeric, hyphens only)"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project))
    error_message = "Project name must be lowercase, alphanumeric, and can contain hyphens."
  }
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environments" {
  description = "Environment configurations"
  type = map(object({
    az_index = number
  }))
  default = {
    dev = {
      az_index = 0
    }
    staging = {
      az_index = 1
    }
    prod = {
      az_index = 2
    }
  }
}
