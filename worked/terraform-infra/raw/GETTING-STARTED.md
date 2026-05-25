# Getting Started Guide

Quick guide to deploy this infrastructure to your AWS account.

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** installed and configured
3. **Terraform** >= 1.0 installed
4. **Basic knowledge** of AWS, Terraform, and Docker

## Step-by-Step Deployment

### 1. Clone This Repository

```bash
git clone <your-repo-url>
cd aws-env-template
```

### 2. Configure AWS CLI

```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Default region: us-east-1
# Default output format: json
```

### 3. Customize Variables

Each module needs a `terraform.tfvars` file. Start with the VPC:

```bash
cd vpc
```

Create `terraform.tfvars`:

```hcl
project = "my-app"  # Change this to your project name
region  = "us-east-1"
```

### 4. Deploy VPC (Foundation)

```bash
terraform init
terraform plan
terraform apply
```

**Expected output**: VPC ID, subnet IDs, NAT gateway IDs

### 5. Deploy Security Groups

```bash
cd ../security-groups
```

Create `terraform.tfvars` using outputs from VPC:

```hcl
project = "my-app"
vpc_id  = "vpc-xxxxx"  # From VPC output
```

```bash
terraform init
terraform apply
```

### 6. Deploy Application Load Balancers

```bash
cd ../alb
```

Create `terraform.tfvars`:

```hcl
project = "my-app"
vpc_id  = "vpc-xxxxx"
public_subnet_ids = {
  dev     = "subnet-xxxxx"
  staging = "subnet-xxxxx"
  prod    = "subnet-xxxxx"
}
alb_security_group_ids = {
  dev     = "sg-xxxxx"
  staging = "sg-xxxxx"
  prod    = "sg-xxxxx"
}
```

```bash
terraform init
terraform apply
```

### 7. Deploy Databases

```bash
cd ../database
```

Create `terraform.tfvars` and `.env`:

**terraform.tfvars:**
```hcl
project = "my-app"
vpc_id  = "vpc-xxxxx"
private_db_subnet_ids = {
  dev     = "subnet-xxxxx"
  staging = "subnet-xxxxx"
  prod    = "subnet-xxxxx"
}
db_security_group_ids = {
  dev     = "sg-xxxxx"
  staging = "sg-xxxxx"
  prod    = "sg-xxxxx"
}
```

**.env:**
```bash
DB_PASSWORD_DEV=YourSecurePassword123!
DB_PASSWORD_STAGING=YourSecurePassword456!
DB_PASSWORD_PROD=YourSecurePassword789!
```

```bash
terraform init
terraform apply
```

### 8. Deploy Container Registry

```bash
cd ../ecr
```

Create `terraform.tfvars`:

```hcl
project = "my-app"
```

```bash
terraform init
terraform apply
```

**Save the outputs**: You'll need the ECR repository URL and GitHub Actions credentials.

### 9. Deploy ECS Fargate

```bash
cd ../ecs
```

Create `terraform.tfvars`:

```hcl
project = "my-app"
vpc_id  = "vpc-xxxxx"
private_app_subnet_ids = {
  dev     = "subnet-xxxxx"
  staging = "subnet-xxxxx"
  prod    = "subnet-xxxxx"
}
ecs_security_group_ids = {
  dev     = "sg-xxxxx"
  staging = "sg-xxxxx"
  prod    = "sg-xxxxx"
}
alb_target_group_arns = {
  dev     = "arn:aws:..."
  staging = "arn:aws:..."
  prod    = "arn:aws:..."
}
db_endpoints = {
  dev     = "xxx.rds.amazonaws.com"
  staging = "xxx.rds.amazonaws.com"
  prod    = "xxx.rds.amazonaws.com"
}
db_password_secret_arns = {
  dev     = "arn:aws:secretsmanager:..."
  staging = "arn:aws:secretsmanager:..."
  prod    = "arn:aws:secretsmanager:..."
}
ecr_repository_url = "xxxxx.dkr.ecr.us-east-1.amazonaws.com/my-app-api"
```

```bash
terraform init
terraform apply
```

### 10. Deploy Bastion Host (Optional)

```bash
cd ../bastion
```

Create `terraform.tfvars`:

```hcl
project = "my-app"
vpc_id  = "vpc-xxxxx"
public_subnet_id = "subnet-xxxxx"  # Any public subnet
bastion_security_group_id = "sg-xxxxx"
```

```bash
terraform init
terraform apply
```

**Save the bastion IP and SSH key** from outputs.

### 11. Deploy Route53 (Optional)

Only if you have a custom domain.

```bash
cd ../route53
```

Create `terraform.tfvars`:

```hcl
project     = "my-app"
domain_name = "example.com"
alb_dns_names = {
  dev     = "xxx.elb.amazonaws.com"
  staging = "xxx.elb.amazonaws.com"
  prod    = "xxx.elb.amazonaws.com"
}
alb_zone_ids = {
  dev     = "Z35SXDOTRQ7X7K"
  staging = "Z35SXDOTRQ7X7K"
  prod    = "Z35SXDOTRQ7X7K"
}
```

```bash
terraform init
terraform apply
```

## Post-Deployment

### 1. Setup GitHub Actions

Add these secrets to your GitHub repository:

- `AWS_ACCESS_KEY_ID` - From ECR outputs
- `AWS_SECRET_ACCESS_KEY` - From ECR outputs

### 2. Deploy Your Application

Push your code to trigger deployment:

```bash
git push origin develop    # Deploys to dev
git push origin staging    # Deploys to staging
git push origin main       # Deploys to production
```

### 3. Access Your Application

Get the ALB URLs from terraform outputs:

```bash
cd alb
terraform output alb_urls
```

Visit: `http://your-app-dev-alb-xxxxx.us-east-1.elb.amazonaws.com`

### 4. Access Databases

Use the bastion host:

```bash
ssh -i ~/.ssh/bastion-key.pem -L 5432:dev-db-endpoint:5432 ubuntu@bastion-ip
psql -h localhost -p 5432 -U postgres -d yourdb
```

## Troubleshooting

### Terraform Errors

- **Dependency errors**: Deploy modules in order
- **State locked**: Wait or force unlock with `terraform force-unlock`
- **Resource exists**: Import existing resources or destroy and recreate

### ECS Tasks Not Starting

- Check CloudWatch logs: `aws logs tail /ecs/my-app-dev --follow`
- Verify ECR image exists
- Check security groups allow ALB → ECS traffic

### Database Connection Issues

- Verify security groups allow ECS → RDS
- Check Secrets Manager passwords
- Test via bastion host

## Next Steps

1. **Setup monitoring**: CloudWatch dashboards and alarms
2. **Configure backups**: RDS automated backups
3. **Add SSL certificates**: ACM for HTTPS
4. **Setup CI/CD**: GitHub Actions workflows
5. **Add custom domain**: Route53 configuration

## Need Help?

- Check module READMEs for detailed instructions
- Review [ARCHITECTURE.md](ARCHITECTURE.md) for infrastructure details
- Open an issue on GitHub

---

**Happy deploying! 🚀**
