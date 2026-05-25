provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "main" {
  id = var.vpc_id
}
