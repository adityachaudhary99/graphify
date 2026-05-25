locals {
  env_azs = {
    for env_name, env_config in var.environments :
    env_name => data.aws_availability_zones.available.names[env_config.az_index]
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block                       = var.vpc_cidr
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true
  
  tags = {
    Name = "${var.project}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${var.project}-igw"
  }
}

# Public Subnets (one per environment)
resource "aws_subnet" "public" {
  for_each = var.environments
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value.az_index)
  availability_zone       = local.env_azs[each.key]
  map_public_ip_on_launch = true
  
  tags = {
    Name        = "${var.project}-${each.key}-public"
    Environment = each.key
    Tier        = "public"
  }
}

# Private App Subnets
resource "aws_subnet" "private_app" {
  for_each = var.environments
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value.az_index + 10)
  availability_zone = local.env_azs[each.key]
  
  tags = {
    Name        = "${var.project}-${each.key}-private-app"
    Environment = each.key
    Tier        = "app"
  }
}

# Private DB Subnets
resource "aws_subnet" "private_db" {
  for_each = var.environments
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value.az_index + 20)
  availability_zone = local.env_azs[each.key]
  
  tags = {
    Name        = "${var.project}-${each.key}-private-db"
    Environment = each.key
    Tier        = "db"
  }
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  for_each = var.environments
  
  domain = "vpc"
  
  tags = {
    Name        = "${var.project}-${each.key}-nat-eip"
    Environment = each.key
  }
  
  depends_on = [aws_internet_gateway.igw]
}

# NAT Gateways (one per environment)
resource "aws_nat_gateway" "nat" {
  for_each = var.environments
  
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
  
  tags = {
    Name        = "${var.project}-${each.key}-nat"
    Environment = each.key
  }
  
  depends_on = [aws_internet_gateway.igw]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  
  tags = {
    Name = "${var.project}-public-rt"
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  for_each = var.environments
  
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

# Private App Route Tables (one per environment)
resource "aws_route_table" "private_app" {
  for_each = var.environments
  
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[each.key].id
  }
  
  tags = {
    Name        = "${var.project}-${each.key}-private-app-rt"
    Environment = each.key
  }
}

# Associate private app subnets with their route tables
resource "aws_route_table_association" "private_app" {
  for_each = var.environments
  
  subnet_id      = aws_subnet.private_app[each.key].id
  route_table_id = aws_route_table.private_app[each.key].id
}

# Private DB Route Tables (no internet access)
resource "aws_route_table" "private_db" {
  for_each = var.environments
  
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name        = "${var.project}-${each.key}-private-db-rt"
    Environment = each.key
  }
}

# Associate private DB subnets with their route tables
resource "aws_route_table_association" "private_db" {
  for_each = var.environments
  
  subnet_id      = aws_subnet.private_db[each.key].id
  route_table_id = aws_route_table.private_db[each.key].id
}
