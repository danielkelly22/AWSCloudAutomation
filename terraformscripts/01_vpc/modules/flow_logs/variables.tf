###################################################################################################################
# Filename   : variables.tf
# Summary    : Variables for the VPC Flow Logs module used by Onica to create an AWS Foundation
# Author     : Sami Meekhaeal (Onica)
# Notes      : 
###################################################################################################################


variable "vpc_id" {
    description = "VPC ID of the VPC created by the VPC module"
}

variable "S3_flow_logs" {
    description = "S3 bucket that contains the flow logs"
}
