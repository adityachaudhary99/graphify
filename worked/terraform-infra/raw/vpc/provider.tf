provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project   = var.project
      ManagedBy = "terraform"
      Owner     = "platform-engineering"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
