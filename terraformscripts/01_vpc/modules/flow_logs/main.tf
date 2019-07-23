###################################################################################################################
# Filename   : main.tf
# Summary    : VPC Flow Logs modules used by Onica to create an AWS Foundation
# Author     : Sami Meekhaeal (Onica)
# Notes      : Used to create VPC Flow logs
###################################################################################################################
terraform {
    required_version = ">= 0.10.3"
}


###################################################################################################################
# VPC Flow Logs
###################################################################################################################
resource "aws_flow_log" "vpc_flow_logs" {
  log_destination      = "arn:aws:s3:::${var.S3_flow_logs}"
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = "${var.vpc_id}"
}
