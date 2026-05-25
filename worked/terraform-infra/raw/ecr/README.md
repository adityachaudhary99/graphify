# ECR - Container Registry

Docker image registry with GitHub Actions credentials.

---

## Quick Deploy

```bash
cd ecr

terraform init
terraform validate
terraform apply
```

---

## What Gets Created

- **ECR Repository**: `your-app-api`
- **Lifecycle Policy**: Keep last 10 images
- **IAM User**: For GitHub Actions
- **Access Keys**: For CI/CD

**Total: 5 resources**

---

## Repository URL

After deployment:
```
<account-id>.dkr.ecr.us-east-1.amazonaws.com/your-app-api
```

Get from terraform output:
```bash
terraform output ecr_repository_url
```

---

## Get GitHub Actions Credentials

```bash
cd ecr

# Access Key ID
terraform output github_actions_access_key_id

# Secret Access Key
terraform output github_actions_secret_access_key
```

**Add these to GitHub Secrets:**
1. Go to repo **Settings** → **Secrets and variables** → **Actions**
2. Add `AWS_ACCESS_KEY_ID`
3. Add `AWS_SECRET_ACCESS_KEY`

---

## Push Image Manually

```bash
# Get ECR URL
ECR_URL=$(terraform output -raw ecr_repository_url)

# Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin $ECR_URL

# Build image
docker build -t your-app-api:latest .

# Tag image
docker tag your-app-api:latest $ECR_URL:latest

# Push image
docker push $ECR_URL:latest
```

---

## View Images

```bash
# List images
aws ecr list-images \
  --repository-name your-app-api \
  --region us-east-1

# Describe images
aws ecr describe-images \
  --repository-name your-app-api \
  --region us-east-1
```

---

## Outputs

```bash
terraform output ecr_repository_url
terraform output ecr_repository_arn
terraform output github_actions_user_name
```

---

## Cost

- **Storage**: $0.10/GB per month
- **Data transfer**: $0.09/GB (out to internet)
- **Typical usage**: ~$3/month

**Total: ~$3/month**

---

## Cleanup

```bash
# Delete all images first
aws ecr batch-delete-image \
  --repository-name your-app-api \
  --image-ids "$(aws ecr list-images --repository-name your-app-api --query 'imageIds[*]' --output json)" \
  --region us-east-1

# Destroy repository
terraform destroy
```
