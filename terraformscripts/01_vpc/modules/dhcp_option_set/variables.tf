###################################################################################################################
# Filename   : variables.tf
# Summary    : Variables for the DHCP Options Set module used by Onica to create an AWS Foundation
# Author     : Sami Meekhaeal (Onica)
# Notes      : 
###################################################################################################################

variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = ""
}

variable "vpc_id" {
    description = "VPC ID of the VPC created by the VPC module"
}

variable "dhcp_options_tags" {
  description = "Additional tags for the DHCP option set"
  default     = {}
}

variable "dhcp_options_domain_name" {
  description = "Specifies DNS name for DHCP options set"
  default     = ""
}

variable "dhcp_options_domain_name_servers" {
  description = "Specify a list of DNS server addresses for DHCP options set, default to AWS provided"

  default = ["AmazonProvidedDNS"]
}

variable "dhcp_options_ntp_servers" {
  description = "Specify a list of NTP servers for DHCP options set"

  default = []
}

variable "dhcp_options_netbios_name_servers" {
  description = "Specify a list of netbios servers for DHCP options set"

  default = []
}

variable "dhcp_options_netbios_node_type" {
  description = "Specify netbios node_type for DHCP options set"
  default     = ""
}variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}