# Review: Terraform Infrastructure Corpus

## Summary

- **84 nodes, 82 edges, 8 communities**, 100% EXTRACTED confidence
- **7 .tf files** (8 including terraform.tfvars as a detected file)
- **0 input / 0 output tokens** — AST-only extraction, no LLM cost

## Detection: 8/10

All 7 Terraform files were correctly classified as `CODE`. The corpus was small (8 files, ~1,793 words) so the "do you need a graph?" warning fired correctly. One minor note: `terraform.tfvars` was counted as a file but its variable assignments are merely value overrides with no structural nodes to extract — harmless noise.

## AST Extraction: 7/10

The Terraform extractor correctly identifies every block type:

| Block Type | Found | Notes |
|-----------|-------|-------|
| `resource` | 23 | EC2, RDS, S3, IAM, monitoring, etc. — all present |
| `data` | 2 | `aws_availability_zones`, `aws_acm_certificate` |
| `variable` | 6 | All input variables |
| `output` | 6 | All output values |
| `module` | 0 | No `module` blocks in this corpus (the example uses direct resource definition) |
| `locals` | 0 | Not used in this corpus |
| `terraform` | 1 | Backend + provider configuration |

Sub-block attributes (like `ingress`/`egress` inside `security_group`, `health_check` inside `target_group`) are correctly extracted as child nodes with `contains` edges. This produces a clean, nested hierarchy that mirrors the HCL block structure.

**What's missing — cross-resource references:** When a `resource` references another resource (e.g., `aws_ecs_task_definition.app` references `aws_db_instance.postgres.address` and `aws_s3_bucket.app.bucket`), these `references` edges are not yet captured. The AST correctly identifies the `variable_expr` + `get_attr` chains (as in `aws_db_instance.postgres.address`), but resolving them into cross-file edges requires a post-processing pass (the Terraform equivalent of `_resolve_cross_file_imports`). This is the single biggest gap.

## Community Quality: 8/10

The 8 communities map almost perfectly to file-level boundaries:

| Community | Cohesion | Contents |
|-----------|----------|---------|
| 0 (compute) | 0.11 | ECS cluster, task def, service, ALB, IAM roles, ECR |
| 1 (storage) | 0.13 | 3 S3 buckets + replication + versioning + IAM replication role |
| 2 (networking) | 0.18 | VPC, subnets, IGW, NAT, security groups, AZs |
| 3 (monitoring) | 0.29 | CloudWatch alarms + SNS topic/subscription |
| 4 (outputs) | 0.29 | All 6 output values |
| 5 (variables) | 0.29 | All 6 input variables |
| 6 (terraform) | 0.33 | Provider config, backend, required_providers |
| 7 (database) | 0.33 | RDS, subnet group, parameter group, random password |

The highest-cohesion communities are the "leaf" modules (terraform config, database) that reference nothing external. The compute community has the lowest cohesion (0.11) because it has the most interconnected resources — which is correct and expected.

**Finding 1:** The community structure precisely recovers the file-level module decomposition. A Terraform practitioner would recognize this as a well-organized project with clear separation of concerns.

**Finding 2:** Variables and outputs form their own communities because they only have `contains` edges from their parent file — no cross-file edges connect them to the resources that use them. This is a consequence of the missing cross-resource references. With those edges, variables would merge into their consumers' communities.

## God Nodes: 6/10

Top god nodes by edge count:

1. `rule` (6 edges) — appears 3 times as a child of different S3 configuration blocks; its high degree is a structural artifact (same label, different nodes collapsed)
2. `aws_ecs_service.app` (3 edges) — the ECS service is a genuine hub
3. `aws_security_group.alb` (3 edges) — referenced by ALB and ECS tasks
4. `ingress` (3 edges) — appears in 3 different security groups

The god node list skews toward attribute-level nodes (like `rule`, `ingress`, `default_action`) because they have `contains` connections to sub-attributes. The true architectural hubs — `aws_vpc.main`, `aws_db_instance.postgres`, `aws_lb.main` — are buried by lower-degree structural nodes.

**Finding 3:** AST-only extraction produces a flat node-degree distribution for Terraform because the graph is dominated by `contains` edges. The real dependency graph would be highly skewed (VPC → everything), but those edges are `references` edges that require the cross-resource resolution pass.

## Surprising Connections: N/A

None detected — all edges are `contains` within single files. Cross-file surprising connections (e.g., the task definition depending on the database and S3) would be the most interesting findings, but they require the reference resolution pass.

## Overall: 7/10

This is a strong first pass. The Terraform extractor correctly handles HCL's block/attribute structure and produces clean, per-file communities. What's missing is the edge that makes Terraform graphs truly useful: cross-resource reference edges that capture the dependency graph (`aws_ecs_task_definition` depends on `aws_db_instance` depends on `aws_db_subnet_group`, etc.).

### Recommendations

1. **Add a cross-file reference resolution pass** (post-extraction) that walks the `variable_expr` + `get_attr` chains and resolves them against the full set of extracted nodes. This is the Terraform equivalent of `_resolve_cross_file_imports` for Python imports.
2. **Handle `template_expr` nodes** — references inside `${...}` template expressions (like `"${var.environment}-cluster"`) also contain resource references that should produce edges.
3. **Handle `for_each` and `count` expressions** — these often reference resources from other modules.
4. **Consider module support** — the extractor handles `module` blocks but the test corpus didn't use them. A follow-up corpus with Terraform Registry modules would exercise this.
