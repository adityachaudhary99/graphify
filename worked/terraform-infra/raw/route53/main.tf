# Hosted Zone (use existing or create new)
data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

# ACM Certificate for HTTPS
resource "aws_acm_certificate" "main" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    Name = var.domain_name
  }
}

# DNS validation records for ACM certificate
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# A Record for Dev API
resource "aws_route53_record" "api_dev" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "api-dev.${var.domain_name}"
  type    = "A"
  
  alias {
    name                   = var.alb_dns_names["dev"]
    zone_id                = var.alb_zone_ids["dev"]
    evaluate_target_health = true
  }
}

# A Record for Staging API
resource "aws_route53_record" "api_staging" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "api-staging.${var.domain_name}"
  type    = "A"
  
  alias {
    name                   = var.alb_dns_names["staging"]
    zone_id                = var.alb_zone_ids["staging"]
    evaluate_target_health = true
  }
}

# A Record for Production API
resource "aws_route53_record" "api_prod" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "api.${var.domain_name}"
  type    = "A"
  
  alias {
    name                   = var.alb_dns_names["prod"]
    zone_id                = var.alb_zone_ids["prod"]
    evaluate_target_health = true
  }
}
