data "aws_route53_zone" "aisk" {
  name = "aisekinet.com"
  private_zone = false
}

resource "aws_route53_record" "aisk" {
  zone_id = data.aws_route53_zone.aisk.zone_id
  name    = data.aws_route53_zone.aisk.name
  type    = "A"

  alias {
    name                   = aws_lb.aisk_prd.dns_name
    zone_id                = aws_lb.aisk_prd.zone_id
    evaluate_target_health = true
  }
}

   
resource "aws_acm_certificate" "aisk" {
  domain_name               = aws_route53_record.aisk.name
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_acm_certificate_validation" "aisk" {
  certificate_arn = aws_acm_certificate.aisk.arn
  validation_record_fqdns = [for record in aws_route53_record.aisk_certificate : record.fqdn]
}

resource "aws_route53_record" "aisk_certificate" {
  for_each = {
    for dvo in aws_acm_certificate.aisk.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  zone_id = data.aws_route53_zone.aisk.zone_id
  type            = each.value.type

  depends_on = [
    aws_acm_certificate.aisk
  ]
}
