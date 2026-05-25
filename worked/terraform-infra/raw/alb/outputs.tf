output "alb_arns" {
  description = "ALB ARNs"
  value = {
    for env, alb in aws_lb.main : env => alb.arn
  }
}

output "alb_dns_names" {
  description = "ALB DNS names"
  value = {
    for env, alb in aws_lb.main : env => alb.dns_name
  }
}

output "alb_zone_ids" {
  description = "ALB zone IDs"
  value = {
    for env, alb in aws_lb.main : env => alb.zone_id
  }
}

output "target_group_arns" {
  description = "Target group ARNs"
  value = {
    for env, tg in aws_lb_target_group.main : env => tg.arn
  }
}

output "alb_urls" {
  description = "ALB URLs"
  value = {
    for env, alb in aws_lb.main : env => "http://${alb.dns_name}"
  }
}
