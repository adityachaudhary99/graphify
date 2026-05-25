# AWS Multi-Environment Terraform — Graph Report

## Overview

| Metric | Value |
|--------|-------|
| Total nodes | 608 |
| Total edges | 733 |
| Reference edges | 168 (cross-file) |
| Unique cross-file pairs | 90 |
| Modules | 8 (VPC, ALB, ECS, ECR, RDS, Bastion, Route53, Security Groups) |
| Files | 54 |
| Resources | 54 |
| Variables | 23 |
| Data sources | 4 |
| Outputs | 40 |

## Graph Structure

The knowledge graph captures the complete dependency structure of a production AWS multi-environment Terraform deployment. Each module is represented as a set of file nodes, with `contains` edges linking blocks (resources, variables, outputs, data sources) to their source files.

### Node Distribution

Attribute nodes (nested block attributes) account for the largest group — these are the individual configuration settings within each resource block. Resource nodes (54) represent actual AWS infrastructure resources like `aws_vpc.main`, `aws_ecs_cluster.main`, `aws_db_instance.dev/staging/prod`, etc.

### Cross-Module References (168 edges)

The Terraform extractor resolves attribute references across file boundaries using stem-independent node IDs. The most heavily referenced targets are shared infrastructure resources:

| Target | Refs | Description |
|--------|------|-------------|
| `variable_domain_name` | 10 | Domain name consumed by Route53, ACM, ALB |
| `resource_aws_vpc_main` | 9 | VPC referenced by Bastion, ALB, ECS, RDS |
| `resource_aws_appautoscaling_target_ecs` | 6 | ECS auto-scaling target |
| `resource_aws_lb_main` | 5 | ALB referenced by Route53, ECS |
| `resource_aws_ecs_cluster_main` | 5 | ECS cluster referenced by services |

### Module Dependencies

The dependency graph shows a clean layered architecture:

```
Internet Gateway → VPC → Security Groups → ALB / Bastion
                                                ↓
                         Route53 → ACM → ALB → ECS → ECR
                                                    ↓
                                               RDS (dev/staging/prod)
```

## Quality Assessment

- **Confidence**: All 733 edges are `EXTRACTED` (confidence_score: 1.0) — derived directly from AST parsing, no inference.
- **Completeness**: Every Terraform block type is captured — resource, data, variable, output, module, locals, terraform.
- **Cross-file resolution**: 168 references resolved across module boundaries. This confirms the stem-independent nid scheme works correctly for multi-module Terraform projects.

## Key Insights

1. `variable_domain_name` is the single most referenced node — a true "god variable" that ties together DNS, TLS, and routing.
2. RDS instances are provisioned per-environment (dev/staging/prod), each referencing shared VPC and security group outputs.
3. The ECS module has the most cross-file references (26 source refs), reflecting its central role connecting ALB, ECR, RDS, and VPC modules.
4. Outputs files (`outputs.tf`) serve as the module interface layer — 58 references originate from output files, showing the module boundary pattern.
