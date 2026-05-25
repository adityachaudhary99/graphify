# ECS - Fargate Clusters

ECS Fargate clusters and services for all environments.

---

## Quick Deploy

```bash
cd ecs

terraform init
terraform validate
terraform apply
```

**Note:** This requires Docker images in ECR. Deploy via GitHub Actions first.

---

## What Gets Created

- **3 ECS Clusters** (dev, staging, prod)
- **3 ECS Services** with ALB integration
- **3 Task Definitions** with DB connections
- **Auto-scaling policies** (CPU & memory)
- **CloudWatch log groups**
- **IAM roles** with Secrets Manager access

**Total: 36 resources**

---

## Clusters

| Environment | Cluster | Capacity | Tasks |
|-------------|---------|----------|-------|
| **Dev** | your-app-dev-cluster | FARGATE_SPOT | 1-4 |
| **Staging** | your-app-staging-cluster | FARGATE_SPOT | 1-4 |
| **Prod** | your-app-prod-cluster | FARGATE | 2-10 |

---

## Services

```bash
# List services
aws ecs list-services --cluster your-app-dev-cluster

# Describe service
aws ecs describe-services \
  --cluster your-app-dev-cluster \
  --services your-app-dev-api-service

# List tasks
aws ecs list-tasks --cluster your-app-dev-cluster

# Describe task
aws ecs describe-tasks \
  --cluster your-app-dev-cluster \
  --tasks <task-arn>
```

---

## View Logs

```bash
# Tail dev logs
aws logs tail /ecs/your-app-dev --follow

# Tail staging logs
aws logs tail /ecs/your-app-staging --follow

# Tail prod logs
aws logs tail /ecs/your-app-prod --follow

# Get recent logs
aws logs tail /ecs/your-app-dev --since 1h
```

---

## Scale Services

```bash
# Scale up dev
aws ecs update-service \
  --cluster your-app-dev-cluster \
  --service your-app-dev-api-service \
  --desired-count 2

# Scale down dev
aws ecs update-service \
  --cluster your-app-dev-cluster \
  --service your-app-dev-api-service \
  --desired-count 0

# Scale prod
aws ecs update-service \
  --cluster your-app-prod-cluster \
  --service your-app-prod-api-service \
  --desired-count 5
```

---

## Force New Deployment

```bash
# Force redeploy with latest image
aws ecs update-service \
  --cluster your-app-dev-cluster \
  --service your-app-dev-api-service \
  --force-new-deployment
```

---

## Outputs

```bash
terraform output ecs_cluster_names
terraform output ecs_service_names
terraform output ecs_task_definition_arns
terraform output cloudwatch_log_groups
```

---

## Auto-Scaling

**Triggers:**
- CPU > 70%
- Memory > 80%

**Scaling:**
- Scale out: 60 seconds cooldown
- Scale in: 300 seconds cooldown

---

## Cost

- **Dev**: ~$15/month (FARGATE_SPOT, 1 task)
- **Staging**: ~$30/month (FARGATE_SPOT, 1 task)
- **Prod**: ~$60/month (FARGATE, 2 tasks)

**Total: ~$105/month**

---

## Troubleshooting

### Tasks Not Starting

```bash
# Check task status
aws ecs describe-tasks \
  --cluster your-app-dev-cluster \
  --tasks $(aws ecs list-tasks --cluster your-app-dev-cluster --query 'taskArns[0]' --output text)

# View logs
aws logs tail /ecs/your-app-dev --follow
```

### Health Checks Failing

- Ensure `/health` endpoint returns 200
- Check CloudWatch logs
- Verify security groups allow ALB → ECS

---

## Cleanup

```bash
# Scale down to 0 first
aws ecs update-service \
  --cluster your-app-dev-cluster \
  --service your-app-dev-api-service \
  --desired-count 0

# Wait for tasks to stop, then destroy
terraform destroy
```
