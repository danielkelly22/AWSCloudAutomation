# resource "aws_acm_certificate" "tfe_cert" {
#   domain_name       = var.tfe_hostname
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = merge({ Name = "${var.friendly_name_prefix}-tfe-alb-acm-cert" }, var.common_tags)
# }

# resource "aws_acm_certificate_validation" "tfe_cert_validation" {
#   certificate_arn         = aws_acm_certificate.tfe_cert.arn
#   validation_record_fqdns = [aws_route53_record.tfe_cert_validation_record.fqdn]
# }
