# AWS Multi-Environment Infrastructure Template

> **Production-ready Terraform infrastructure for deploying containerized applications on AWS**

A complete, modular Terraform setup that provisions a full AWS infrastructure with separate dev, staging, and production environments. Perfect for teams looking to deploy scalable, secure, and cost-optimized containerized applications.

---

## 🌟 Overview

This template provides everything you need to run a production-grade containerized application on AWS:

- **🏗️ Complete Infrastructure**: VPC, Load Balancers, Databases, Container Services, and more
- **🔒 Security First**: Private subnets, security groups, bastion host for secure access
- **📈 Auto-Scaling**: ECS Fargate with CPU/memory-based scaling
- **💰 Cost Optimized**: FARGATE_SPOT for non-prod, right-sized instances
- **🚀 CI/CD Ready**: GitHub Actions integration with ECR
- **🌍 Multi-Environment**: Fully isolated dev, staging, and production environments
- **📊 Observable**: CloudWatch logs and metrics built-in

**Total Resources**: ~113 AWS resources across all environments

---

## 🎯 What Gets Deployed

### Infrastructure Components

| Component | Description | Environments |
|-----------|-------------|--------------|
| **VPC** | Multi-AZ with public/private subnets, NAT gateways | Shared |
| **ALB** | Application Load Balancers with health checks | 3 (dev, staging, prod) |
| **ECS Fargate** | Serverless container orchestration with auto-scaling | 3 (dev, staging, prod) |
| **RDS PostgreSQL** | Managed databases (Multi-AZ for prod) | 3 (dev, staging, prod) |
| **ECR** | Private Docker container registry | Shared |
| **Bastion Host** | Secure SSH access to databases | Shared |
| **Route53** | DNS management (optional) | Shared |
| **Secrets Manager** | Secure credential storage | 3 (dev, staging, prod) |
| **CloudWatch** | Logs and monitoring | All resources |
| **GitHub Actions** | Automated CI/CD pipeline | Included |

### Environment Specifications

| Resource | Dev | Staging | Production |
|----------|-----|---------|------------|
| **ECS Tasks** | 1-4 (SPOT) | 1-4 (SPOT) | 2-10 (On-Demand) |
| **Task Size** | 256 CPU / 512 MB | 256 CPU / 512 MB | 512 CPU / 1024 MB |
| **RDS Instance** | db.t3.medium | db.t3.large | db.r6g.2xlarge |
| **RDS Storage** | 20 GB | 50 GB | 100-1000 GB (auto-scale) |
| **Multi-AZ** | No | No | Yes |
| **Backups** | 7 days | 7 days | 30 days |

## 📁 Repository Structure

```
aws-env-template/
├── 📂 vpc/                 # VPC, subnets, NAT gateways, routing
├── 📂 security-groups/     # Security groups for ALB, ECS, RDS
├── 📂 alb/                 # Application Load Balancers
├── 📂 database/            # RDS PostgreSQL databases
├── 📂 ecr/                 # Container registry
├── 📂 ecs/                 # ECS Fargate clusters & services
├── 📂 bastion/             # Bastion host for DB access
├── 📂 route53/             # DNS configuration (optional)
├── 📂 ci-cd/               # GitHub Actions workflow for deployments
├── 📄 ARCHITECTURE.md      # Detailed architecture documentation
├── 📄 GETTING-STARTED.md   # Step-by-step deployment guide
├── 📄 architecture.mmd     # Mermaid diagram
└── 📄 README.md            # This file
```

Each module is self-contained with:
- `main.tf` - Resource definitions
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `README.md` - Module-specific documentation
- `terraform.tfvars` - **You create this with your values**

---

## 🚀 Quick Start

### Prerequisites

- ✅ AWS account with appropriate permissions
- ✅ AWS CLI installed and configured (`aws configure`)
- ✅ Terraform >= 1.0 installed
- ✅ Basic knowledge of AWS, Terraform, and Docker

### Deployment

**📖 See [GETTING-STARTED.md](GETTING-STARTED.md) for detailed step-by-step instructions.**

**Quick overview:**

1. **Clone** this repository
2. **Configure** each module's `terraform.tfvars` with your project name
3. **Deploy** modules in order: VPC → Security Groups → ALB → Database → ECR → ECS → Bastion → Route53
4. **Deploy** your application using the ECR repository and GitHub Actions

**Deployment time**: ~30-45 minutes for all modules

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| **[GETTING-STARTED.md](GETTING-STARTED.md)** | Complete step-by-step deployment guide |
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | Detailed architecture diagrams and explanations |
| **[ci-cd/README.md](ci-cd/README.md)** | GitHub Actions CI/CD setup and configuration |
| **[architecture.mmd](architecture.mmd)** | Mermaid diagrams (view on GitHub) |
| **Module READMEs** | Specific instructions for each infrastructure component |

## 🏗️ Architecture Overview

### High-Level Flow

```
┌─────────────┐
│   Internet  │
│   (Users)   │
└──────┬──────┘
       │
       ↓
┌──────────────────────┐
│  Application Load    │
│     Balancer         │  ← Public Subnet
└──────┬───────────────┘
       │
       ↓
┌──────────────────────┐
│   ECS Fargate        │
│   (Auto-scaling)     │  ← Private App Subnet
└──────┬───────────────┘
       │
       ↓
┌──────────────────────┐
│  RDS PostgreSQL      │
│  (Multi-AZ for prod) │  ← Private DB Subnet
└──────────────────────┘
```

### Key Features

| Feature | Description |
|---------|-------------|
| **🌍 Multi-Environment** | Fully isolated dev, staging, and production environments |
| **📈 Auto-Scaling** | ECS tasks scale based on CPU and memory metrics |
| **🔒 Security** | Private subnets, security groups, encrypted databases |
| **🚀 High Availability** | Multi-AZ deployment for production databases and load balancers |
| **📊 Monitoring** | CloudWatch logs, metrics, and alarms for all services |
| **🔄 CI/CD Ready** | GitHub Actions workflows for automated deployments |
| **💾 Backup & Recovery** | Automated RDS backups (7-30 days retention) |
| **🔐 Secrets Management** | AWS Secrets Manager for database credentials |

**📖 See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed diagrams and network flow explanations.**

## 💰 Cost Breakdown

### Monthly Estimate (All 3 Environments)

| Service | Dev | Staging | Prod | Monthly Total |
|---------|-----|---------|------|---------------|
| **NAT Gateway** | $32 | $32 | $32 | $96 |
| **ALB** | $16 | $16 | $16 | $48 |
| **ECS Fargate** | $15 | $30 | $60 | $105 |
| **RDS PostgreSQL** | $50 | $100 | $200 | $350 |
| **ECR** | $1 | $1 | $1 | $3 |
| **Secrets Manager** | $1.20 | $1.20 | $1.20 | $3.60 |
| **Bastion Host** | - | - | $7.50 | $7.50 |
| **Total** | **~$115** | **~$180** | **~$318** | **~$613/month** |

### Cost Optimization

This template includes several cost optimizations:

- ✅ **FARGATE_SPOT** for dev/staging (50% cheaper than on-demand)
- ✅ **Right-sized instances** (smaller for dev, larger for prod)
- ✅ **RDS storage auto-scaling** (pay only for what you use)
- ✅ **Lifecycle policies** on ECR (keep only recent images)

**Additional savings:**
- 💡 Stop dev/staging environments during off-hours (~40% savings)
- 💡 Use Reserved Instances for production RDS (~30% savings)
- 💡 Enable S3 lifecycle policies for logs (~50% savings on storage)

---

## 🔧 Customization

This template is designed to be easily customizable:

### Project Name
Update the `project` variable in each module's `terraform.tfvars`:
```hcl
project = "my-app"
```

### AWS Region
Change the `region` variable to deploy in a different region:
```hcl
region = "ap-south-1"
```

### Resource Sizing
Adjust resources in module `main.tf` files:
- **ECS**: Task count, CPU/memory allocation
- **RDS**: Instance class, storage size
- **VPC**: CIDR blocks, subnet configuration

**📖 See each module's README for specific customization options.**

---

## 🛠️ Operations

### Monitoring & Logging

All resources include CloudWatch integration:
- **ECS Logs**: `/ecs/<project>-<env>`
- **RDS Logs**: Automated to CloudWatch
- **ALB Access Logs**: Optional S3 bucket

**View logs:**
```bash
aws logs tail /ecs/your-app-dev --follow
```

### Backups

- **RDS**: Automated daily backups (7-30 days retention)
- **Snapshots**: Manual snapshots before major changes
- **Secrets**: Versioned in Secrets Manager

### Scaling

- **ECS**: Auto-scales based on CPU/memory (configured per environment)
- **RDS**: Manual scaling (requires brief downtime)
- **ALB**: Automatically scales with traffic

**📖 See [GETTING-STARTED.md](GETTING-STARTED.md) for operational procedures.**

---

## 🗑️ Cleanup

To destroy all infrastructure:

```bash
# See GETTING-STARTED.md for detailed cleanup instructions
cd route53 && terraform destroy
cd ../bastion && terraform destroy
cd ../ecs && terraform destroy
# ... (continue in reverse order)
```

⚠️ **WARNING**: This deletes everything including databases! Take backups first.

---

## ❓ FAQ

<details>
<summary><b>Can I use this for a single environment?</b></summary>

Yes! Simply deploy only the modules you need for one environment. Modify the Terraform code to remove the environment loops.
</details>

<details>
<summary><b>Does this support HTTPS/SSL?</b></summary>

The ALB is configured for HTTP. For HTTPS, add an ACM certificate and update the ALB listener. See `alb/README.md` for instructions.
</details>

<details>
<summary><b>Can I use Aurora instead of RDS?</b></summary>

Yes! Modify `database/main.tf` to use Aurora PostgreSQL. Note: Aurora is more expensive but offers better scalability.
</details>

<details>
<summary><b>How do I add more environments?</b></summary>

Add the environment to the `environments` variable in each module and run `terraform apply`.
</details>

<details>
<summary><b>Is this production-ready?</b></summary>

Yes! This template follows AWS best practices and is suitable for production workloads. However, review and adjust based on your specific requirements.
</details>

---

## 🐛 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| **ECS tasks not starting** | Check CloudWatch logs, verify ECR image exists |
| **ALB health checks failing** | Ensure `/health` endpoint returns 200, check security groups |
| **Database connection errors** | Verify security groups, check Secrets Manager passwords |
| **Terraform state locked** | Wait for other operations to complete or force unlock |

**📖 See [GETTING-STARTED.md](GETTING-STARTED.md) for detailed troubleshooting steps.**

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### How to Contribute

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**TL;DR**: You can use this template for personal or commercial projects, modify it, and distribute it freely.

---

## 🙏 Acknowledgments

- Built following AWS Well-Architected Framework best practices
- Inspired by real-world production deployments
- Community feedback and contributions

---

## 📞 Support

- 📖 **Documentation**: Check [GETTING-STARTED.md](GETTING-STARTED.md) and module READMEs
- 🐛 **Issues**: [Open an issue](../../issues) on GitHub
- 💬 **Discussions**: [Start a discussion](../../discussions) for questions
- ⭐ **Star this repo** if you find it helpful!

---

<div align="center">

**Built with ❤️ for production-ready AWS deployments**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)](https://aws.amazon.com/)

**[⬆ Back to Top](#aws-multi-environment-infrastructure-template)**

</div>
