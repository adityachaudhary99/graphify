# Bastion Host Setup

Simple bastion host for secure database access via SSH tunneling.

---

## Quick Setup

### 1. Create EC2 Key Pair

```bash
# Create new key pair
aws ec2 create-key-pair \
  --key-name your-app-bastion \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/your-app-bastion.pem

# Set permissions
chmod 400 ~/.ssh/your-app-bastion.pem
```

### 2. Deploy Bastion

```bash
terraform init
terraform validate
terraform apply
```

### 3. Get Connection Info

```bash
terraform output bastion_public_ip
terraform output ssh_command
```

---

## SSH Tunnel Setup

### Connect to Dev Database

**Terminal 1 - Start Tunnel:**
```bash
ssh -i ~/.ssh/bastion-key.pem \
    -L 5432:<your-dev-db-endpoint>:5432 \
    ubuntu@<bastion-ip>
```

**Terminal 2 - Connect to Database:**
```bash
# Get password
aws secretsmanager get-secret-value \
  --secret-id your-app-dev-db-password-v2 \
  --region us-east-1 \
  --query SecretString --output text

# Connect (paste password when prompted)
psql -h localhost -p 5432 -U postgres -d yourdb
```

### Connect to Staging Database

**Terminal 1 - Start Tunnel:**
```bash
ssh -i ~/.ssh/bastion-key.pem \
    -L 5433:<your-staging-db-endpoint>:5432 \
    ubuntu@<bastion-ip>
```

**Terminal 2 - Connect:**
```bash
# Get password
aws secretsmanager get-secret-value \
  --secret-id your-app-staging-db-password-v2 \
  --region us-east-1 \
  --query SecretString --output text

# Connect
psql -h localhost -p 5433 -U postgres -d yourdb
```

### Connect to Prod Database

**Terminal 1 - Start Tunnel:**
```bash
ssh -i ~/.ssh/bastion-key.pem \
    -L 5434:<your-prod-db-endpoint>:5432 \
    ubuntu@<bastion-ip>
```

**Terminal 2 - Connect:**
```bash
# Get password
aws secretsmanager get-secret-value \
  --secret-id your-app-prod-db-password-v2 \
  --region us-east-1 \
  --query SecretString --output text

# Connect
psql -h localhost -p 5434 -U postgres -d yourdb
```

---

## Quick Reference

### Bastion IP
```bash
# Get from terraform output
terraform output bastion_public_ip
```

### Database Passwords
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

### One-Line Tunnel + Connect

**Dev:**
```bash
# Terminal 1
ssh -i ~/.ssh/bastion-key.pem -L 5432:<dev-db-endpoint>:5432 ubuntu@<bastion-ip>

# Terminal 2
psql -h localhost -p 5432 -U postgres -d yourdb
# Password: (from Secrets Manager)
```

**Staging:**
```bash
# Terminal 1
ssh -i ~/.ssh/bastion-key.pem -L 5433:<staging-db-endpoint>:5432 ubuntu@<bastion-ip>

# Terminal 2
psql -h localhost -p 5433 -U postgres -d yourdb
# Password: (from Secrets Manager)
```

**Prod:**
```bash
# Terminal 1
ssh -i ~/.ssh/bastion-key.pem -L 5434:<prod-db-endpoint>:5432 ubuntu@<bastion-ip>

# Terminal 2
psql -h localhost -p 5434 -U postgres -d yourdb
# Password: (from Secrets Manager)
```

---

## Local Development with Tunnel

### Setup .env.local

```bash
# Terminal 1: Start tunnel
ssh -i ~/.ssh/bastion-key.pem \
    -L 5432:<dev-db-endpoint>:5432 \
    ubuntu@<bastion-ip>

# Terminal 2: Update .env.local
cat > .env.local << EOF
NODE_ENV=development
PORT=3000
DB_HOST_WRITE=localhost
DB_HOST_READ=localhost
DB_PORT=5432
DB_NAME=yourdb
DB_USER=postgres
DB_PASSWORD=<paste-password-here>
EOF

# Run API
npm run dev
```

---

## Direct SSH to Bastion

```bash
# SSH to bastion
ssh -i ~/.ssh/bastion-key.pem ubuntu@<bastion-ip>

# Once on bastion, connect to database directly
psql -h <dev-db-endpoint> \
     -p 5432 -U postgres -d yourdb
```

---

## GUI Tools (DBeaver, pgAdmin)

### DBeaver Setup

1. **Start SSH tunnel:**
   ```bash
   ssh -i ~/.ssh/bastion-key.pem \
       -L 5432:<dev-db-endpoint>:5432 \
       ubuntu@<bastion-ip>
   ```

2. **In DBeaver:**
   - Host: `localhost`
   - Port: `5432`
   - Database: `yourdb`
   - Username: `postgres`
   - Password: (from Secrets Manager)

### pgAdmin Setup

Same as DBeaver - use `localhost:5432` while tunnel is active.

---

## Multiple Tunnels at Once

Run all three tunnels in background:

```bash
# Dev on port 5432
ssh -i ~/.ssh/bastion-key.pem \
    -L 5432:<dev-db-endpoint>:5432 \
    -N -f ubuntu@<bastion-ip>

# Staging on port 5433
ssh -i ~/.ssh/bastion-key.pem \
    -L 5433:<staging-db-endpoint>:5432 \
    -N -f ubuntu@<bastion-ip>

# Prod on port 5434
ssh -i ~/.ssh/bastion-key.pem \
    -L 5434:<prod-db-endpoint>:5432 \
    -N -f ubuntu@<bastion-ip>

# Now connect to any environment
psql -h localhost -p 5432 -U postgres -d yourdb  # Dev
psql -h localhost -p 5433 -U postgres -d yourdb  # Staging
psql -h localhost -p 5434 -U postgres -d yourdb  # Prod

# Kill tunnels when done
pkill -f "ssh.*5432"
pkill -f "ssh.*5433"
pkill -f "ssh.*5434"
```

---

## Troubleshooting

### Can't SSH to Bastion

```bash
# Check security group allows your IP
terraform output bastion_security_group_id

# Verify your current IP
curl ifconfig.me

# Update terraform.tfvars if IP changed
vim terraform.tfvars
terraform apply
```

### Tunnel Connection Refused

```bash
# Check bastion is running
aws ec2 describe-instances \
  --instance-ids $(terraform output -raw bastion_instance_id)

# Check database security groups allow bastion
aws ec2 describe-security-groups \
  --group-ids <db-security-group-id>
```

### Permission Denied (SSH Key)

```bash
# Fix key permissions
chmod 400 ~/.ssh/bastion-key.pem
```

---

## Cost

- **t3.micro instance**: ~$7.50/month
- **Elastic IP**: Free (while attached)
- **Data transfer**: Minimal

**Total: ~$7.50/month**

---

## Cleanup

```bash
terraform destroy
```

**Note:** This will remove bastion access to databases.

---

## Summary

**Setup:**
1. Create key pair
2. Get your IP
3. Update terraform.tfvars
4. Run `terraform apply`

**Use:**
```bash
# Start tunnel
ssh -i ~/.ssh/bastion-key.pem \
    -L 5432:<dev-db-endpoint>:5432 \
    ubuntu@<bastion-ip>

# Connect
psql -h localhost -p 5432 -U postgres -d yourdb
```

**That's it!** 🎉
