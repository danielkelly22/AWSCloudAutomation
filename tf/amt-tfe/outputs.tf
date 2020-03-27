##################################
# DNS
##################################
# output "tfe_app_url" {
#   value = aws_route53_record.tfe_alb_alias_record.name
# }

# output "tfe_admin_console_url" {
#   value = "${aws_route53_record.tfe_alb_alias_record.name}:8800"
# }
##################################
# Load Balancer
##################################
output "tfe_alb_dns_name" {
  value = aws_lb.tfe_alb.dns_name
}

##################################
# storage
##################################
output "tfe_app_bucket_name" {
  value = aws_s3_bucket.tfe_app.id
}
