# Application Load Balancer

ALBs for dev, staging, and production environments.

---

## Quick Deploy

```bash
cd alb

terraform init
terraform validate
terraform apply
```

---

## What Gets Created

- **3 Application Load Balancers** (dev, staging, prod)
- **3 Target Groups** (for ECS services)
- **3 HTTP Listeners** (port 80)
- Health checks configured

**Total: 6 resources**

---

## Endpoints

After deployment, you'll get ALB DNS names like:

| Environment | Example URL |
|-------------|-------------|
| **Dev** | http://your-app-dev-alb-xxxxxxxx.us-east-1.elb.amazonaws.com |
| **Staging** | http://your-app-staging-alb-xxxxxxxx.us-east-1.elb.amazonaws.com |
| **Production** | http://your-app-prod-alb-xxxxxxxx.us-east-1.elb.amazonaws.com |

---

## Test

```bash
# Get ALB URLs
terraform output alb_urls

# Test dev ALB (will return 503 until ECS is deployed)
curl $(terraform output -json alb_urls | jq -r '.dev')

# Check health
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -json target_group_arns | jq -r '.dev')
```

---

## Outputs

```bash
terraform output alb_dns_names
terraform output alb_urls
terraform output target_group_arns
terraform output alb_zone_ids
```

---

## Health Check Settings

- **Path**: `/health`
- **Interval**: 30 seconds
- **Timeout**: 5 seconds
- **Healthy threshold**: 2
- **Unhealthy threshold**: 3

---

## Cost

- **ALB**: ~$16/month each × 3 = **$48/month**
- **LCU hours**: ~$8/month per ALB
- **Data processed**: ~$0.008/GB

**Total: ~$72/month**

---

## Cleanup

```bash
terraform destroy
```

**Note:** Destroy ECS services first before destroying ALB.
