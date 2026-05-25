# Graph Report - worked\terraform-infra\raw  (2026-05-25)

## Corpus Check
- 8 files · ~1,793 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 84 nodes · 82 edges · 8 communities
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `43baaf19`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]

## God Nodes (most connected - your core abstractions)
1. `rule` - 6 edges
2. `aws_ecs_service.app` - 3 edges
3. `terraform` - 3 edges
4. `aws_security_group.alb` - 3 edges
5. `ingress` - 3 edges
6. `aws_security_group.ecs_tasks` - 3 edges
7. `aws_ecs_cluster.main` - 2 edges
8. `aws_lb_target_group.app` - 2 edges
9. `aws_lb_listener.main` - 2 edges
10. `aws_ecr_repository.app` - 2 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Communities (8 total, 0 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.11
Nodes (18): aws_acm_certificate.main, default_action, health_check, image_scanning_configuration, load_balancer, network_configuration, aws_cloudwatch_log_group.app, aws_ecr_repository.app (+10 more)

### Community 1 - "Community 1"
Cohesion: 0.13
Nodes (17): apply_server_side_encryption_by_default, destination, expiration, aws_iam_role_policy.replication, aws_iam_role.replication, aws_s3_bucket.app, aws_s3_bucket.backups, aws_s3_bucket.dr_backups (+9 more)

### Community 2 - "Community 2"
Cohesion: 0.18
Nodes (13): aws_availability_zones.available, egress, ingress, aws_eip.nat, aws_internet_gateway.main, aws_nat_gateway.main, aws_security_group.alb, aws_security_group.database (+5 more)

### Community 3 - "Community 3"
Cohesion: 0.29
Nodes (6): aws_cloudwatch_metric_alarm.alb_5xx, aws_cloudwatch_metric_alarm.cpu_high, aws_cloudwatch_metric_alarm.db_connections, aws_cloudwatch_metric_alarm.memory_high, aws_sns_topic.alerts, aws_sns_topic_subscription.alerts_email

### Community 4 - "Community 4"
Cohesion: 0.29
Nodes (6): alb_dns_name, app_bucket, db_endpoint, ecs_cluster_name, sns_topic_arn, vpc_id

### Community 5 - "Community 5"
Cohesion: 0.29
Nodes (6): app_port, aws_region, db_instance_class, environment, instance_count, vpc_cidr

### Community 6 - "Community 6"
Cohesion: 0.33
Nodes (5): backend, provider, required_providers, random_pet.suffix, terraform

### Community 7 - "Community 7"
Cohesion: 0.33
Nodes (5): parameter, aws_db_instance.postgres, aws_db_parameter_group.postgres, aws_db_subnet_group.main, random_password.db_master

## Knowledge Gaps
- **57 isolated node(s):** `setting`, `aws_ecs_task_definition.app`, `network_configuration`, `load_balancer`, `aws_lb.main` (+52 more)
  These have ≤1 connection - possible missing edges or undocumented components.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What connects `setting`, `aws_ecs_task_definition.app`, `network_configuration` to the rest of the system?**
  _57 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.11 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.13 - nodes in this community are weakly interconnected._