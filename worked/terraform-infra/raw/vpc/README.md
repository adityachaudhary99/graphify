# VPC Setup

Multi-AZ VPC with public, private app, and private DB subnets.

---

## Quick Deploy

```bash
cd vpc

terraform init
terraform validate
terraform apply
```

---

## What Gets Created

- **VPC**: `10.0.0.0/16`
- **3 Availability Zones** (us-east-1a, 1b, 1c)
- **Public Subnets**: For ALB (3 subnets)
- **Private App Subnets**: For ECS tasks (3 subnets)
- **Private DB Subnets**: For databases (3 subnets)
- **Internet Gateway**: For public internet access
- **NAT Gateways**: One per AZ (3 total)
- **Route Tables**: Configured for each subnet type

**Total: 33 resources**

---

## Outputs

```bash
terraform output vpc_id
terraform output public_subnet_ids
terraform output private_app_subnet_ids
terraform output private_db_subnet_ids
terraform output nat_gateway_ips
```

---

## Verify

```bash
# Check VPC
aws ec2 describe-vpcs --vpc-ids $(terraform output -raw vpc_id)

# Check subnets
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$(terraform output -raw vpc_id)"

# Check NAT gateways
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$(terraform output -raw vpc_id)"
```

---

## Cost

- **VPC**: Free
- **NAT Gateways**: $32/month each × 3 = **$96/month**
- **Data transfer**: ~$0.09/GB

**Total: ~$96/month**

---

## Cleanup

```bash
terraform destroy
```

**Note:** Destroy other resources first (ECS, ALB, databases) before destroying VPC.
