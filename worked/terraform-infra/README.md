# Terraform Worked Example

This directory contains a **production-ready AWS multi-environment Terraform template** extracted into a graphify knowledge graph.

The Terraform code comes from [github.com/adityachaudhary99/aws-terraform-multi-env-template](https://github.com/adityachaudhary99/aws-terraform-multi-env-template) — a real infrastructure-as-code project with modular architecture, CI/CD, and dev/staging/prod environments.

## What this demonstrates

- **Terraform/HCL extraction** — graphify's `extract_terraform()` walker parses `.tf` files using `tree-sitter-hcl`, producing structured nodes for every block type: resources, data sources, variables, outputs, modules, and locals.
- **Cross-file reference resolution** — attribute references like `var.domain_name` and `aws_vpc.main.id` are resolved into `references` edges across module boundaries via stem-independent node IDs.
- **Real-world complexity** — 54 files across 8 modules (VPC, ALB, ECS, ECR, RDS, Bastion, Route53, Security Groups) producing 608 nodes and 733 edges.

## Graph Stats

| Metric | Value |
|--------|-------|
| Nodes | 608 |
| Edges | 733 |
| Cross-file refs | 168 |
| Resources | 54 |
| Modules | 8 |

## Files

| File | Description |
|------|-------------|
| `raw/` | Terraform source files (copied from upstream template) |
| `graph.json` | Full extracted knowledge graph |
| `GRAPH_REPORT.md` | Analysis of graph structure and findings |

## Usage

```bash
# Extract the graph from scratch
graphify extract raw/

# Or use the pre-generated graph
graphify build . --graph graph.json
```
