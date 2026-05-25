resource "aws_instance" "web" {
  ami           = "ami-12345"
  instance_type = "t2.micro"

  tags = {
    Name = "web-server"
  }
}

resource "aws_s3_bucket" "data" {
  bucket = "my-app-data"
  acl    = "private"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}

output "instance_ip" {
  value       = aws_instance.web.public_ip
  description = "The public IP of the web instance"
}

output "bucket_arn" {
  value       = aws_s3_bucket.data.arn
  description = "The ARN of the data bucket"
}

locals {
  environment = "production"
  name_prefix = "my-app"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
}
