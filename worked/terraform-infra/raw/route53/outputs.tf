output "certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  value       = aws_acm_certificate.main.arn
}

output "certificate_status" {
  description = "ACM certificate validation status"
  value       = aws_acm_certificate.main.status
}

output "domain_endpoints" {
  description = "Custom domain endpoints"
  value = {
    dev     = "https://api-dev.${var.domain_name}"
    staging = "https://api-staging.${var.domain_name}"
    prod    = "https://api.${var.domain_name}"
  }
}

output "nameservers" {
  description = "Route53 nameservers (add these to your domain registrar)"
  value       = data.aws_route53_zone.main.name_servers
}

output "dns_records" {
  description = "DNS records created"
  value = {
    dev     = aws_route53_record.api_dev.fqdn
    staging = aws_route53_record.api_staging.fqdn
    prod    = aws_route53_record.api_prod.fqdn
  }
}
