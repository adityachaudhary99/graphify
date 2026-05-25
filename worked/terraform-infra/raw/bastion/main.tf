# Get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group for Bastion
resource "aws_security_group" "bastion" {
  name        = "${var.project}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id

  # SSH from your IP
  ingress {
    description = "SSH from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.your_ip]
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-bastion-sg"
  }
}

# Update database security groups to allow bastion
resource "aws_security_group_rule" "db_from_bastion" {
  for_each = var.db_security_group_ids

  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = each.value
  description              = "PostgreSQL from bastion"
}

# No IAM role needed for simple SSH bastion

# Bastion EC2 Instance
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = var.key_name
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.bastion.id]

  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -e
    
    # Update system
    apt-get update
    apt-get upgrade -y
    
    # Install PostgreSQL client
    apt-get install -y postgresql-client
    
    # Install useful tools
    apt-get install -y htop vim curl wget jq
    
    echo "Bastion setup complete!" > /home/ubuntu/setup-complete.txt
  EOF

  tags = {
    Name = "${var.project}-bastion"
  }
}

# Elastic IP for Bastion (optional but recommended)
resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  domain   = "vpc"

  tags = {
    Name = "${var.project}-bastion-eip"
  }
}
