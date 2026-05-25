# CI/CD Configuration

GitHub Actions workflow for automated deployment to AWS ECS.

---

## 📁 Contents

```
ci-cd/
└── .github/
    └── workflows/
        └── deploy.yml    # GitHub Actions deployment workflow
```

**Note**: You'll need to create `.github/workflows/deploy.yml` in your application repository. See setup instructions below.

---

## 🚀 How It Works

This workflow automatically deploys your application to the appropriate environment based on the branch:

| Branch | Environment | Cluster | Trigger |
|--------|-------------|---------|---------|
| `develop` | Dev | `your-app-dev-cluster` | Push to develop |
| `staging` | Staging | `your-app-staging-cluster` | Push to staging |
| `main` | Production | `your-app-prod-cluster` | Push to main |

---

## 📋 Setup Instructions

### 1. Copy Workflow to Your Repository

```bash
# Copy the workflow file to your application repository
cp -r ci-cd/.github /path/to/your/app/repo/
```

### 2. Update Configuration

Edit `.github/workflows/deploy.yml`:

```yaml
env:
  AWS_REGION: us-east-1
  ECR_REPOSITORY: your-app-api  # Change to your ECR repository name
```

Update cluster and service names (lines 28-40):
```yaml
ECS_CLUSTER=your-app-prod-cluster        # Match your terraform output
ECS_SERVICE=your-app-prod-api-service    # Match your terraform output
TASK_DEFINITION=your-app-prod-api        # Match your terraform output
```

### 3. Add GitHub Secrets

Go to your repository **Settings** → **Secrets and variables** → **Actions**

Add these secrets (get from ECR terraform output):

```bash
# Get credentials from terraform
cd ecr
terraform output github_actions_access_key_id
terraform output github_actions_secret_access_key
```

Add to GitHub:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### 4. Create Branches

```bash
# Create develop branch
git checkout -b develop
git push origin develop

# Create staging branch
git checkout -b staging
git push origin staging

# Main branch should already exist
```

---

## 🔄 Deployment Workflow

### What Happens on Push

1. **Checkout Code** - Gets latest code from repository
2. **Set Environment** - Determines environment based on branch
3. **Configure AWS** - Authenticates with AWS using secrets
4. **Login to ECR** - Authenticates with container registry
5. **Build Docker Image** - Builds your application container
6. **Tag Image** - Tags with commit SHA and environment
7. **Push to ECR** - Uploads image to container registry
8. **Update Task Definition** - Updates ECS task with new image
9. **Deploy to ECS** - Deploys new version to cluster
10. **Wait for Stability** - Ensures deployment succeeded

### Image Tagging Strategy

Each deployment creates 3 tags:

```
<commit-sha>                 # e.g., abc123def456
<env>-latest                 # e.g., prod-latest
<env>-<commit-sha>           # e.g., prod-abc123def456
```

This allows:
- **Rollback** to specific commits
- **Latest** always points to most recent deployment
- **Environment-specific** tags for easy identification

---

## 📊 Monitoring Deployments

### View Workflow Runs

1. Go to your repository on GitHub
2. Click **Actions** tab
3. See all deployment runs and their status

### Check Deployment Status

```bash
# View ECS service
aws ecs describe-services \
  --cluster your-app-prod-cluster \
  --services your-app-prod-api-service

# View running tasks
aws ecs list-tasks \
  --cluster your-app-prod-cluster \
  --service-name your-app-prod-api-service

# View logs
aws logs tail /ecs/your-app-prod --follow
```

---

## 🔧 Customization

### Add Environment Variables

Add to the workflow under the deploy step:

```yaml
- name: Deploy to Amazon ECS
  env:
    MY_CUSTOM_VAR: value
```

### Add Tests Before Deploy

Add before the build step:

```yaml
- name: Run tests
  run: |
    npm install
    npm test
```

### Add Slack Notifications

Add at the end:

```yaml
- name: Notify Slack
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Deploy on Pull Request

Add to `on:` section:

```yaml
on:
  push:
    branches: [main, staging, develop]
  pull_request:
    branches: [main, staging, develop]
```

---

## 🐛 Troubleshooting

### Deployment Fails

**Check GitHub Actions logs:**
1. Go to Actions tab
2. Click on failed run
3. Expand failed step

**Common issues:**

| Error | Solution |
|-------|----------|
| **Authentication failed** | Check AWS secrets are correct |
| **Image push failed** | Verify ECR repository exists |
| **Task definition not found** | Ensure ECS service is deployed |
| **Service update failed** | Check ECS service is running |

### Rollback Deployment

```bash
# List recent images
aws ecr describe-images \
  --repository-name your-app-api \
  --query 'sort_by(imageDetails,& imagePushedAt)[-10:]'

# Update service with previous image
aws ecs update-service \
  --cluster your-app-prod-cluster \
  --service your-app-prod-api-service \
  --force-new-deployment \
  --task-definition your-app-prod-api:<previous-revision>
```

---

## 📝 Best Practices

1. **✅ Always test in dev first** - Push to develop before staging/main
2. **✅ Use pull requests** - Review code before merging to main
3. **✅ Monitor deployments** - Check GitHub Actions and CloudWatch
4. **✅ Tag releases** - Use git tags for production deployments
5. **✅ Keep secrets secure** - Never commit AWS credentials
6. **✅ Enable branch protection** - Require reviews for main/staging

---

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS ECS Deploy Action](https://github.com/aws-actions/amazon-ecs-deploy-task-definition)
- [ECR Login Action](https://github.com/aws-actions/amazon-ecr-login)

---

## 🎯 Example Deployment Flow

```bash
# 1. Develop feature
git checkout -b feature/new-feature
# ... make changes ...
git commit -m "Add new feature"

# 2. Deploy to dev
git checkout develop
git merge feature/new-feature
git push origin develop
# ✅ Auto-deploys to dev environment

# 3. Test in dev, then promote to staging
git checkout staging
git merge develop
git push origin staging
# ✅ Auto-deploys to staging environment

# 4. Test in staging, then promote to production
git checkout main
git merge staging
git push origin main
# ✅ Auto-deploys to production environment
```

---

**🚀 Happy Deploying!**
