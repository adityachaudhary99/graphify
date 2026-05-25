variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  type        = string
  description = "Your domain name (e.g., yourdomain.com)"
}

variable "alb_dns_names" {
  type = map(string)
  description = "ALB DNS names from ALB outputs"
}

variable "alb_zone_ids" {
  type = map(string)
  description = "ALB hosted zone IDs from ALB outputs"
}
