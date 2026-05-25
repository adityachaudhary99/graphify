output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value = {
    for env, subnet in aws_subnet.public : env => subnet.id
  }
}

output "private_app_subnet_ids" {
  description = "Private app subnet IDs"
  value = {
    for env, subnet in aws_subnet.private_app : env => subnet.id
  }
}

output "private_db_subnet_ids" {
  description = "Private DB subnet IDs"
  value = {
    for env, subnet in aws_subnet.private_db : env => subnet.id
  }
}

output "nat_gateway_ips" {
  description = "NAT Gateway public IPs"
  value = {
    for env, eip in aws_eip.nat : env => eip.public_ip
  }
}
