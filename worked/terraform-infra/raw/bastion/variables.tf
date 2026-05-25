variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  description = "Project name used for resource naming"
  type        = string
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnet_id" {
  type        = string
  description = "Public subnet ID for bastion"
}

variable "db_security_group_ids" {
  type        = map(string)
  description = "Database security group IDs"
}

variable "your_ip" {
  type        = string
  description = "Your IP address for SSH access (e.g., 1.2.3.4/32)"
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name"
}
