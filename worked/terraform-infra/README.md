# Terraform Infrastructure Corpus Benchmark

A 7-file Terraform codebase modeling a production-grade multi-tier AWS infrastructure. Tests graphify on HashiCorp Configuration Language (HCL) — the first non-general-purpose DSL supported by graphify's AST extractor.

## Corpus (7 files)

```
raw/
├── main.tf          — Terraform/provider config, backend, random_pet suffix
├── variables.tf     — Input variables (region, environment, instance sizes, ports)
├── networking.tf    — VPC, subnets (public/private/database), IGW, NAT, security groups
├── compute.tf       — ECS cluster, task definition, service, ALB, IAM roles, ECR, CloudWatch logs
├── database.tf      — RDS PostgreSQL, subnet group, parameter group, random password
├── storage.tf       — S3 buckets (app data, logs, backups), replication, IAM replication role
├── monitoring.tf    — CloudWatch alarms (CPU, memory, DB connections, 5xx), SNS topic + subscription
└── outputs.tf       — Outputs for VPC ID, ALB DNS, cluster name, DB endpoint, bucket name, SNS ARN
```

Architecture: a load-balanced Fargate service running behind an ALB, backed by RDS PostgreSQL, with S3 for application data and backups, CloudWatch monitoring, and SNS alerting. Cross-resource references span every file — the task definition references the RDS address, the ALB references the target group, alarms reference the cluster and service, and IAM policies reference S3 bucket ARNs.

## How to run

```bash
pip install graphifyy

graphify install                        # Claude Code
graphify install --platform codex       # Codex
graphify install --platform opencode    # OpenCode
graphify install --platform claw        # OpenClaw
```

Then open your AI coding assistant in this directory and type:

```
/graphify ./raw
```

## What to expect

- 100+ AST nodes: resources, data sources, variables, outputs, locals, and modules — one of the most structurally diverse corpora supported
- God nodes: `aws_vpc.main`, `aws_ecs_cluster.main`, `aws_db_instance.postgres` — the core infrastructure primitives that everything else depends on
- Cross-file references: the `aws_ecs_task_definition.app` references `aws_db_instance.postgres` (database.tf), `aws_s3_bucket.app` (storage.tf), and `aws_cloudwatch_log_group.app` (monitoring.tf) — spanning 4 files
- Token reduction: moderate — 8 files of HCL is small, but the dense cross-referencing produces a richer graph than a same-sized Python corpus

This is the first time graphify has been applied to a DSL (domain-specific language) corpus. It demonstrates that graphify's tree-sitter extraction pipeline generalizes beyond general-purpose languages to infrastructure-as-code. Actual output is in this folder: `GRAPH_REPORT.md` and `graph.json`. Full evaluation: `review.md`.
