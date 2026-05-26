# Worked Example — Observations

## Summary

Ran the experimental Terraform extractor against a multi-environment AWS infrastructure template (54 `.tf` files across 8 modules: VPC, ALB, ECS, ECR, RDS, Bastion, Route53, security groups). Observations below; not claims of completeness.

## What the run produced

- **Block-type coverage observed in the output:** the seven HCL block types in this corpus (resource, data, module, variable, output, locals, terraform settings) appear as typed nodes with `contains` hierarchy edges. Provider blocks are not present in this corpus; coverage on those was not exercised.
- **Attribute-level granularity (opinionated):** the current extractor emits individual configuration values (e.g., `instance_type`, `bucket`, `vpc_id`) as child nodes of their parent blocks. This is a denser graph than block-level-only extraction. Whether this density is the right default is a design question, not a fact.
- **Cross-file reference edges observed:** 168 `references` edges were created across file boundaries — e.g., `ecs/main.tf` referencing `aws_vpc.main` declared in `vpc/main.tf`, and `route53/main.tf` consuming `aws_lb.main.dns_name` from `alb/main.tf`. This is enabled by the stem-independent nid scheme, which has a known trade-off: same-named resources across distinct modules collapse to one node (not the case in this corpus, but worth flagging for multi-module deployments).
- **`outputs.tf` as interface layer:** 58 of the 168 cross-file references originate from `output` declarations. Consistent with how the Terraform community typically structures module boundaries, but this is a description of this corpus, not a benchmark.

## Graph properties (as measured on this run)

| Metric | Value |
|---|---|
| Files | 54 |
| Modules | 8 |
| Nodes | 608 |
| Edges | 733 |
| Cross-file `references` edges | 168 |
| Parse errors | 0 |
| Edges with `confidence: EXTRACTED` | 733 (all) |

Highest in-degree nodes in the run: `variable_domain_name` (10 references), `resource_aws_vpc_main` (9 references), `resource_aws_lb_main` (5 references). These correspond to the most-shared dependencies in the template.

## Known limitations of the extractor used in this run

- The stem-independent nid scheme treats two `modules/X/main.tf` files declaring same-named resources as one node. Not exercised here but a real risk on larger multi-module repos.
- The resource-reference resolver in this branch returns the first nid candidate without an existence check, which can produce phantom edges when an attribute access incidentally matches the `<word>.<word>` shape.
- No diagnostics for unresolved refs — they are silently dropped.
- No secret scrubbing on persisted strings; for production use the diagnostics + scrubbing in [PR #416](https://github.com/safishamsi/graphify/pull/416) are the better foundation.

## What this run does NOT establish

- **Not** that "all references in the corpus are captured" — that would require an oracle for "all references that exist" and no such oracle was constructed.
- **Not** that the extractor is production-ready — see limitations above.
- **Not** a benchmark against alternative extractors (e.g., #416) — different design choices; no head-to-head ran.

## Useful as

A reference graph for talking about what Graphify-style indexing reveals about real Terraform corpora — module boundaries, shared dependencies, output-layer fan-in. The `graph.json` and `GRAPH_REPORT.md` are the artifacts; this file is the surrounding context.
