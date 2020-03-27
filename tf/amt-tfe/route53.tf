# data "aws_route53_zone" "selected" {
#   name         = var.route53_hosted_zone_name
#   private_zone = false
# }

# resource "aws_route53_record" "tfe_alb_alias_record" {
#   zone_id = data.aws_route53_zone.selected.zone_id
#   name    = var.tfe_hostname
#   type    = "A"

#   alias {
#     name                   = aws_lb.tfe_alb.dns_name
#     zone_id                = aws_lb.tfe_alb.zone_id
#     evaluate_target_health = false
#   }
# }

# resource "aws_route53_record" "tfe_cert_validation_record" {
#   name    = aws_acm_certificate.tfe_cert.domain_validation_options[0].resource_record_name
#   type    = aws_acm_certificate.tfe_cert.domain_validation_options[0].resource_record_type
#   zone_id = data.aws_route53_zone.selected.zone_id
#   records = [aws_acm_certificate.tfe_cert.domain_validation_options[0].resource_record_value]
#   ttl     = 60
# }
