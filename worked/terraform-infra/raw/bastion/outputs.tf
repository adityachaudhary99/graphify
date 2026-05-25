output "bastion_public_ip" {
  description = "Bastion host public IP"
  value       = aws_eip.bastion.public_ip
}

output "bastion_instance_id" {
  description = "Bastion instance ID"
  value       = aws_instance.bastion.id
}

output "bastion_security_group_id" {
  description = "Bastion security group ID"
  value       = aws_security_group.bastion.id
}

output "ssh_command" {
  description = "SSH command to connect to bastion"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_eip.bastion.public_ip}"
}

output "ssh_tunnel_commands" {
  description = "SSH tunnel commands for database access"
  value = {
    dev = "ssh -i ~/.ssh/${var.key_name}.pem -L 5432:survey-app-dev-postgres.cydum20qq92u.us-east-1.rds.amazonaws.com:5432 ubuntu@${aws_eip.bastion.public_ip}"
    staging = "ssh -i ~/.ssh/${var.key_name}.pem -L 5433:survey-app-staging-postgres.cydum20qq92u.us-east-1.rds.amazonaws.com:5432 ubuntu@${aws_eip.bastion.public_ip}"
    prod = "ssh -i ~/.ssh/${var.key_name}.pem -L 5434:survey-app-prod-postgres.cydum20qq92u.us-east-1.rds.amazonaws.com:5432 ubuntu@${aws_eip.bastion.public_ip}"
  }
}
