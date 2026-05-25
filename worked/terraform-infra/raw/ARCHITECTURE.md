# AWS Multi-Environment Infrastructure Architecture

## Infrastructure Overview

This document describes the architecture of the multi-environment AWS infrastructure deployed using Terraform.

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                  INTERNET                                        │
│                          (Users, GitHub Actions)                                 │
└────────────────────────────────┬────────────────────────────────────────────────┘
                                 │
                          Internet Gateway
                                 │
        ┌────────────────────────┼────────────────────────┐
        │                        │                        │
┌───────▼────────┐    ┌──────────▼──────────┐    ┌───────▼────────┐
│  AZ: us-east-1a│    │  AZ: us-east-1b     │    │  AZ: us-east-1c│
│  DEV ENVIRONMENT│    │ STAGING ENVIRONMENT │    │ PROD ENVIRONMENT│
├────────────────┤    ├─────────────────────┤    ├────────────────┤
│                │    │                     │    │                │
│ PUBLIC SUBNET  │    │  PUBLIC SUBNET      │    │  PUBLIC SUBNET │
│ 10.0.0.0/24    │    │  10.0.1.0/24        │    │  10.0.2.0/24   │
│ ┌────────────┐ │    │ ┌─────────────┐     │    │ ┌────────────┐ │
│ │    ALB     │ │    │ │     ALB     │     │    │ │    ALB     │ │
│ │ :80, :443  │ │    │ │  :80, :443  │     │    │ │ :80, :443  │ │
│ └────────────┘ │    │ └─────────────┘     │    │ └────────────┘ │
│ ┌────────────┐ │    │ ┌─────────────┐     │    │ ┌────────────┐ │
│ │NAT Gateway │ │    │ │ NAT Gateway │     │    │ │NAT Gateway │ │
│ │ (EIP)      │ │    │ │   (EIP)     │     │    │ │  (EIP)     │ │
│ └────────────┘ │    │ └─────────────┘     │    │ └────────────┘ │
│                │    │                     │    │                │
│ PRIVATE APP    │    │  PRIVATE APP        │    │  PRIVATE APP   │
│ 10.0.10.0/24   │    │  10.0.11.0/24       │    │  10.0.12.0/24  │
│ ┌────────────┐ │    │ ┌─────────────┐     │    │ ┌────────────┐ │
│ │ECS Fargate │ │    │ │ ECS Fargate │     │    │ │ECS Fargate │ │
│ │ 1-4 tasks  │ │    │ │  1-4 tasks  │     │    │ │ 2-10 tasks │ │
│ │FARGATE_SPOT│ │    │ │ FARGATE_SPOT│     │    │ │  FARGATE   │ │
│ │ 256/512    │ │    │ │  256/512    │     │    │ │  512/1024  │ │
│ └────────────┘ │    │ └─────────────┘     │    │ └────────────┘ │
│                │    │                     │    │                │
│ PRIVATE DB     │    │  PRIVATE DB         │    │  PRIVATE DB    │
│ 10.0.20.0/24   │    │  10.0.21.0/24       │    │  10.0.22.0/24  │
│ ┌────────────┐ │    │ ┌─────────────┐     │    │ ┌────────────┐ │
│ │    RDS     │ │    │ │     RDS     │     │    │ │    RDS     │ │
│ │PostgreSQL  │ │    │ │ PostgreSQL  │     │    │ │ PostgreSQL │ │
│ │    17.5    │ │    │ │    17.5     │     │    │ │    17.5    │ │
│ │db.t3.medium│ │    │ │ db.t3.large │     │    │ │db.r6g.2xlarge│
│ │  20 GB     │ │    │ │   50 GB     │     │    │ │  100 GB    │ │
│ │ 7d backup  │ │    │ │  7d backup  │     │    │ │  30d backup│ │
│ └────────────┘ │    │ └─────────────┘     │    │ └────────────┘ │
└────────────────┘    └─────────────────────┘    └────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                        SHARED SERVICES                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │     ECR      │  │   Secrets    │  │   Bastion    │             │
│  │  Repository  │  │   Manager    │  │     Host     │             │
│  │              │  │              │  │              │             │
│  │  your-app    │  │ 3 passwords  │  │  t3.micro    │             │
│  │    -api      │  │ (dev/stg/prd)│  │ Public IP    │             │
│  └──────────────┘  └──────────────┘  └──────────────┘             │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Endpoints (After Deployment)

### Application Load Balancers

After deployment, you'll get ALB DNS names like:

| Environment | Example DNS Name |
|-------------|------------------|
| **Dev** | your-app-dev-alb-xxxxxxxx.us-east-1.elb.amazonaws.com |
| **Staging** | your-app-staging-alb-xxxxxxxx.us-east-1.elb.amazonaws.com |
| **Production** | your-app-prod-alb-xxxxxxxx.us-east-1.elb.amazonaws.com |

### Databases

| Environment | Type | Example Endpoint |
|-------------|------|------------------|
| **Dev** | RDS PostgreSQL 17.5 | your-app-dev-postgres.xxxxx.us-east-1.rds.amazonaws.com:5432 |
| **Staging** | RDS PostgreSQL 17.5 | your-app-staging-postgres.xxxxx.us-east-1.rds.amazonaws.com:5432 |
| **Production** | RDS PostgreSQL 17.5 (Multi-AZ) | your-app-prod-postgres.xxxxx.us-east-1.rds.amazonaws.com:5432 |

### Container Registry

```
<account-id>.dkr.ecr.us-east-1.amazonaws.com/your-app-api
```

### Bastion Host

```
ubuntu@<bastion-public-ip>
```

---

## Network Flow

### User Request Flow

\`\`\`
User Browser
    ↓
Internet Gateway
    ↓
Application Load Balancer (Public Subnet)
    ↓
ECS Fargate Tasks (Private App Subnet)
    ↓
RDS Database (Private DB Subnet)
\`\`\`

### CI/CD Deployment Flow

\`\`\`
GitHub Actions
    ↓
ECR (Push Docker Image)
    ↓
ECS Service (Pull & Deploy)
    ↓
ALB Health Check
    ↓
Live Traffic
\`\`\`

### Database Access Flow

\`\`\`
Developer
    ↓
SSH Tunnel → Bastion Host (Public Subnet)
    ↓
Database (Private DB Subnet)
\`\`\`

---

## Resource Summary

### Total Resources: 113

| Category | Count | Resources |
|----------|-------|-----------|
| **Networking** | 33 | VPC, Subnets, NAT Gateways, Route Tables |
| **Security** | 9 | Security Groups |
| **Load Balancing** | 6 | ALBs, Target Groups |
| **Databases** | 8 | RDS PostgreSQL, Secrets Manager |
| **Container Registry** | 5 | ECR, IAM |
| **ECS** | 36 | Clusters, Services, Tasks, Auto-scaling |
| **Bastion** | 6 | EC2, Security Groups |

---

## Key Features

### High Availability
- ✅ Multi-AZ deployment (3 availability zones)
- ✅ Auto-scaling ECS tasks
- ✅ RDS Multi-AZ (prod)
- ✅ Cross-zone load balancing
- ✅ Automated backups

### Security
- ✅ Private subnets for app and database
- ✅ Security groups with least privilege
- ✅ Secrets Manager for passwords
- ✅ Encrypted databases
- ✅ Bastion host for secure access

### Scalability
- ✅ ECS auto-scaling (CPU/memory based)
- ✅ RDS auto-scaling storage (100GB-1TB)
- ✅ RDS storage auto-scaling
- ✅ Load balanced traffic

### Cost Optimization
- ✅ FARGATE_SPOT for dev/staging (50% cheaper)
- ✅ Right-sized instances per environment
- ✅ Auto-scaling (pay for what you use)

---

## Monthly Cost Breakdown

| Service | Cost |
|---------|------|
| NAT Gateways (3) | \$96 |
| ALBs (3) | \$48 |
| ECS Fargate | \$105 |
| RDS (dev + staging) | \$150 |
| RDS Prod (Multi-AZ) | \$200 |
| ECR | \$3 |
| Secrets Manager | \$3.60 |
| Bastion | \$7.50 |
| **Total** | **~\$613/month** |

---

## VPC Details

| Component | Value |
|-----------|-------|
| **VPC ID** | $VPC_ID |
| **CIDR** | 10.0.0.0/16 |
| **Region** | us-east-1 |
| **Availability Zones** | us-east-1a, us-east-1b, us-east-1c |

---

## Auto-Scaling Configuration

### Dev & Staging
- **Min Tasks**: 1
- **Max Tasks**: 4
- **CPU Target**: 70%
- **Memory Target**: 80%
- **Capacity**: FARGATE_SPOT

### Production
- **Min Tasks**: 2
- **Max Tasks**: 10
- **CPU Target**: 70%
- **Memory Target**: 80%
- **Capacity**: FARGATE

---

## Database Configuration

### Dev
- **Instance**: db.t3.medium (2 vCPU, 4 GB RAM)
- **Storage**: 20 GB → 100 GB (auto-scaling)
- **Backups**: 7 days
- **Multi-AZ**: No

### Staging
- **Instance**: db.t3.large (2 vCPU, 8 GB RAM)
- **Storage**: 50 GB → 200 GB (auto-scaling)
- **Backups**: 7 days
- **Multi-AZ**: No

### Production
- **Cluster**: 3 instances (1 writer + 2 readers)
- **Instance**: db.r6g.xlarge (4 vCPU, 32 GB RAM)
- **Storage**: Auto-scaling
- **Backups**: 30 days
- **Multi-AZ**: Yes

---

**Last Updated:** 2025-01-XX
