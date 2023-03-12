data "aws_route53_zone" "naked" {
  name = "ymnk.fun"
}

resource "aws_acm_certificate" "main" {
  domain_name       = "api.ymnk.fun"
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.main_acm_c : record.fqdn]
}

resource "aws_route53_record" "main_acm_c" {
  for_each = {
    for d in aws_acm_certificate.main.domain_validation_options : d.domain_name => {
      name   = d.resource_record_name
      record = d.resource_record_value
      type   = d.resource_record_type
    }
  }
  zone_id         = data.aws_route53_zone.naked.id
  name            = each.value.name
  type            = each.value.type
  ttl             = 172800
  records         = [each.value.record]
  allow_overwrite = true
}

resource "aws_route53_record" "api" {
  type    = "A"
  name    = "api.ymnk.fun"
  zone_id = data.aws_route53_zone.naked.id
  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}