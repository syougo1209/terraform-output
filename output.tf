output "alb_dns_name" {
  value = aws_lb.aisk_prd.dns_name
}

output "domain_name" {
  value = aws_route53_record.aisk.name
}
