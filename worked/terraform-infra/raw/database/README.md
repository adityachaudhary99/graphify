# Databases

RDS PostgreSQL for all environments (dev, staging, production).

---

## Quick Deploy

```bash
cd database

terraform init
terraform validate
terraform apply
```

**Note:** This takes ~10-15 minutes to create RDS instances.

---

## What Gets Created

### Dev Environment
- RDS PostgreSQL 17.5
- Instance: `db.t3.medium`
- Storage: 20GB
- Single AZ

### Staging Environment
- RDS PostgreSQL 17.5
- Instance: `db.t3.large`
- Storage: 50GB
- Single AZ

### Production Environment
- RDS PostgreSQL 17.5
- Instance: `db.r6g.2xlarge`
- Storage: 100GB → 1TB (auto-scaling)
- Multi-AZ (high availability)

### Additional
- Secrets Manager for passwords
- Automated backups
- DB subnet groups

**Total: 8 resources**

---

## Endpoints

After deployment, you'll get endpoints like:

| Environment | Example Endpoint | Port |
|-------------|------------------|------|
| **Dev** | your-app-dev-postgres.xxxxx.us-east-1.rds.amazonaws.com | 5432 |
| **Staging** | your-app-staging-postgres.xxxxx.us-east-1.rds.amazonaws.com | 5432 |
| **Production** | your-app-prod-postgres.xxxxx.us-east-1.rds.amazonaws.com | 5432 |

---

## Get Passwords

```bash
# Dev
aws secretsmanager get-secret-value \
  --secret-id your-app-dev-db-password-v2 \
  --region us-east-1 \
  --query SecretString --output text

# Staging
aws secretsmanager get-secret-value \
  --secret-id your-app-staging-db-password-v2 \
  --region us-east-1 \
  --query SecretString --output text

# Prod
aws secretsmanager get-secret-value \
  --secret-id your-app-prod-db-password-v2 \
  --region us-east-1 \
  --query SecretString --output text
```

---

## Connect via Bastion

See [bastion/README.md](../bastion/README.md) for SSH tunnel setup.

**Quick connect to dev:**
```bash
# Terminal 1 - SSH tunnel (replace with your values)
ssh -i ~/.ssh/bastion-key.pem \
    -L 5432:<your-dev-db-endpoint>:5432 \
    ubuntu@<bastion-ip>

# Terminal 2 - Connect to database
psql -h localhost -p 5432 -U postgres -d yourdb
```

---

## Outputs

```bash
terraform output database_endpoints
terraform output db_secret_arns
terraform output prod_rds_endpoint
```

---

## Verify

```bash
# Check RDS instances
aws rds describe-db-instances \
  --query 'DBInstances[?DBInstanceIdentifier==`your-app-dev-postgres`]'

# Check Prod RDS
aws rds describe-db-instances \
  --query 'DBInstances[?DBInstanceIdentifier==`your-app-prod-postgres`]'
```

---

## Cost

- **Dev RDS**: ~$50/month
- **Staging RDS**: ~$100/month
- **Prod RDS**: ~$200/month (Multi-AZ)
- **Secrets Manager**: $3.60/month
- **Backups**: Included (7-30 days)

**Total: ~$353/month**

---

## Cleanup

```bash
terraform destroy
```

**Warning:** This will delete all data! Take backups first.
