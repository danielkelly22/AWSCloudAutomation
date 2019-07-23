###################################################################################################################
# Filename   : variables.tf
# Summary    : Variables for the Config module used by Onica to create an AWS Foundation
# Author     : Clayton Davis (Onica)
# Notes      : 
###################################################################################################################
variable "prefix_name" {
    description = "It Will be appended to config rule names"
}
variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}