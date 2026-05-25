# Route53 & Domain Setup

Custom domain with HTTPS for all environments.

---

## Quick Setup

### 1. Create Hosted Zone

```bash
# Create hosted zone for your domain
aws route53 create-hosted-zone \
  --name yourdomain.com \
  --caller-reference $(date +%s) \
  --region us-east-1

# Get hosted zone ID
aws route53 list-hosted-zones \
  --query "HostedZones[?Name=='yourdomain.com.'].Id" \
  --output text
```

### 2. Update terraform.tfvars

```bash
vim terraform.tfvars
```

Change `domain_name`:
```hcl
domain_name = "yourdomain.com"
```

### 3. Deploy

```bash
terraform init
terraform validate
terraform apply
```

### 4. Update Nameservers at Registrar

```bash
# Get nameservers
terraform output nameservers
```

Add these to your domain registrar:
- **GoDaddy**: DNS Management → Nameservers → Change → Custom
- **Namecheap**: Domain List → Manage → Nameservers → Custom DNS
- **Other**: Find DNS/Nameserver settings

### 5. Wait & Verify

```bash
# Check DNS propagation (takes 10-60 minutes)
dig api.yourdomain.com

# Check certificate status
terraform output certificate_status

# Get your endpoints
terraform output domain_endpoints
```

---

## What Gets Created

| Resource | Name | Purpose |
|----------|------|---------|
| ACM Certificate | `*.yourdomain.com` | SSL/TLS for HTTPS |
| DNS Validation | CNAME records | Validates certificate |
| A Record | `api-dev.yourdomain.com` | Dev API endpoint |
| A Record | `api-staging.yourdomain.com` | Staging API endpoint |
| A Record | `api.yourdomain.com` | Production API endpoint |

---

## Enable HTTPS on ALB

After certificate is validated:

```bash
cd alb

# Get certificate ARN
CERT_ARN=$(cd ../route53 && terraform output -raw certificate_arn)

# Create HTTPS listener file
cat > https-listener.tf << 'EOF'
variable "acm_certificate_arn" {
  type    = string
  default = ""
}

resource "aws_lb_listener" "https" {
  for_each = var.acm_certificate_arn != "" ? toset(["dev", "staging", "prod"]) : toset([])
  
  load_balancer_arn = aws_lb.main[each.key].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[each.key].arn
  }
}

# Redirect HTTP to HTTPS
resource "aws_lb_listener_rule" "redirect_http_to_https" {
  for_each = var.acm_certificate_arn != "" ? toset(["dev", "staging", "prod"]) : toset([])
  
  listener_arn = aws_lb_listener.http[each.key].arn
  priority     = 1
  
  action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
EOF

# Apply
terraform apply -var="acm_certificate_arn=$CERT_ARN"
```

---

## Test Your Endpoints

```bash
# Test dev
curl https://api-dev.yourdomain.com/health

# Test staging
curl https://api-staging.yourdomain.com/health

# Test prod
curl https://api.yourdomain.com/health
```

**Your URLs:**
- Dev: `https://api-dev.yourdomain.com`
- Staging: `https://api-staging.yourdomain.com`
- Production: `https://api.yourdomain.com`

---

## Troubleshooting

**Certificate pending validation:**
```bash
# Check validation records
terraform output certificate_status

# Verify nameservers
dig NS yourdomain.com
```

**DNS not resolving:**
```bash
# Check A record
dig api.yourdomain.com

# Check from Google DNS
dig @8.8.8.8 api.yourdomain.com
```

**HTTPS not working:**
- Wait for certificate validation (can take 30 minutes)
- Verify ALB HTTPS listener is created
- Check security group allows port 443

---

## Cost

- Hosted Zone: $0.50/month
- DNS Queries: $0.40/million queries
- ACM Certificate: **FREE**

**Total: ~$0.50/month**
