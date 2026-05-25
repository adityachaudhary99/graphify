# Security Groups

Security groups for ALB, ECS tasks, and databases.

---

## Quick Deploy

```bash
cd security-groups

terraform init
terraform validate
terraform apply
```

---

## What Gets Created

### ALB Security Groups (3)
- Allow HTTP (80) from internet
- Allow HTTPS (443) from internet
- One per environment (dev, staging, prod)

### ECS Task Security Groups (3)
- Allow traffic from ALB only
- Allow port 80 from ALB
- One per environment

### Database Security Groups (3)
- Allow PostgreSQL (5432) from ECS tasks only
- One per environment

**Total: 9 resources**

---

## Security Rules

| Source | Destination | Port | Protocol |
|--------|-------------|------|----------|
| Internet (0.0.0.0/0) | ALB | 80, 443 | TCP |
| ALB | ECS Tasks | 80 | TCP |
| ECS Tasks | Database | 5432 | TCP |
| Bastion | Database | 5432 | TCP |

---

## Outputs

```bash
terraform output alb_security_group_ids
terraform output ecs_tasks_security_group_ids
terraform output rds_security_group_ids
```

---

## Verify

```bash
# Check ALB security group
aws ec2 describe-security-groups \
  --group-ids $(terraform output -json alb_security_group_ids | jq -r '.dev')

# Check ECS security group
aws ec2 describe-security-groups \
  --group-ids $(terraform output -json ecs_tasks_security_group_ids | jq -r '.dev')

# Check RDS security group
aws ec2 describe-security-groups \
  --group-ids $(terraform output -json rds_security_group_ids | jq -r '.dev')
```

---

## Cost

**Free** - No charge for security groups

---

## Cleanup

```bash
terraform destroy
```
