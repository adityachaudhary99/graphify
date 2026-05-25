variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  description = "Project name used for resource naming"
  type        = string
}

variable "vpc_id" {
  type    = string
  default = "vpc-0fe52e3eb5428413a"
}

# From Step 1: VPC
variable "public_subnet_ids" {
  type = map(string)
  default = {
    dev     = "subnet-07df22198412764e1"
    staging = "subnet-0895af788cde2c0d6"
    prod    = "subnet-093886cf87fdecdbb"
  }
}

# From Step 2: Security Groups
variable "alb_security_group_ids" {
  type = map(string)
  default = {
    dev     = "sg-0d0c8ae1bebac6dec"
    staging = "sg-0f8c874d40bc8a78b"
    prod    = "sg-0276bd33f12853336"
  }
}

variable "environments" {
  type    = list(string)
  default = ["dev", "staging", "prod"]
}
