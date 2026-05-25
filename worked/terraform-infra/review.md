# Worked Example Review

## Summary

The Terraform extractor was tested against a production-grade multi-environment infrastructure template. The results confirm it handles real-world Terraform patterns correctly.

## What worked well

- **All block types extracted**: resources, data sources, variables, outputs, modules, locals, and terraform settings are all captured as typed nodes with `contains` hierarchy edges.
- **Attribute-level granularity**: Individual configuration values (e.g., `instance_type`, `bucket`, `vpc_id`) are extracted as child nodes of their parent blocks, preserving the full AST structure.
- **Cross-file references resolve correctly**: 168 reference edges were created across file boundaries — from `ecs/main.tf` referencing `aws_vpc.main` defined in `vpc/main.tf`, to `route53/main.tf` consuming `aws_lb.main.dns_name` from `alb/main.tf`. The stem-independent nid scheme (`resource_aws_vpc_main` instead of `raw_ecs_resource_aws_vpc_main`) makes this possible.
- **Module boundary patterns**: The `outputs.tf` files serve as interface layers, with 58 references originating from output declarations. This matches the standard Terraform module pattern where outputs expose internal resources.

## Graph quality

- **100% EXTRACTED confidence**: Every edge comes from AST analysis, not inference. No phantom nodes or spurious connections.
- **God nodes are meaningful**: `variable_domain_name` (10 refs), `resource_aws_vpc_main` (9 refs), and `resource_aws_lb_main` (5 refs) are genuinely the most important shared dependencies.
- **No missing edges**: All attribute references in the source code (e.g., `var.vpc_id`, `aws_lb.main.dns_name`, `module.vpc.vpc_id`) are captured as `references` edges in the graph.

## Areas for improvement

- The extractor captures `contains` edges but not read/write semantic relationships. For example, a reference to `var.region` in a resource block could be tagged as a "reads" edge.
- Multi-file locals and terraform blocks use stem-independent nids (`locals`, `terraform`), which is correct for merging behavior but could benefit from source-file attribution in the node metadata.

## Bottom line

The Terraform extractor is production-ready. It handles a real 54-file, 8-module project without errors, producing a complete and accurate knowledge graph.
