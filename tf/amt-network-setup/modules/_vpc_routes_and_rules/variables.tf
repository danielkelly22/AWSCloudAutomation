variable "environment_affix" {
  description = "The short environment name (to be affixed to names)"
  type        = string
}

variable "subnets" {
  description = "The subnets to which the transit gateway will be attached. Should be one per availability zone."
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC to which the transit gateway will be attached."
  type        = string
}

variable "transit_gateway_id" {
  description = "The ID of the transit gateway."
  type        = string
}

variable "vpn_transit_gateway_attachment_id" {
  description = "The ID of the VPN transit gateway attachment"
  type        = string
}

variable "skip_gateway_attachment_acceptance" {
  description = "Set this to true if the VPC and the transit gateway are in the same account. Defaults to false."
  type        = bool
  default     = false
}

variable "transit_gateway_default_route_table_association" {
  description = "See the docs"
  type        = bool
  default     = false
}

variable "transit_gateway_default_route_table_propagation" {
  description = "See the docs"
  type        = bool
  default     = false
}

variable "transit_gateway_egress_cidr_blocks" {
  description = ""
  type        = map(string)
  default = {
    quad-zeroes     = "0.0.0.0/0"
    tens            = "10.0.0.0/8"
    one-seventy-two = "172.16.0.0/12"
    one-ninety-two  = "192.168.0.0/16"
  }
}

variable "internet_routable_cidr_blocks" {
  description = "The internet CIDR blocks that are routable through the transit gateway."
  type        = map(string)
  default = {
    quad-zeroes = "0.0.0.0/0"
  }
}

variable "aws_routable_cidr_blocks" {
  description = "The CIDR blocks for AWS VPCs"
  type        = map(string)
  default     = {}
}

variable "vpn_routable_cidr_blocks" {
  description = "The CIDR addresses for VPN routes"
  type        = map(string)
  # default = {
  #   tens            = "10.0.0.0/8",
  #   one-seventy-two = "172.16.0.0/12",
  #   one-ninety-two  = "192.168.0.0/16"
  # }
  default = {} # todo replace when VPN is available
}

variable "blackhole_cidr_blocks" {
  description = "A list of addresses to black hole."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "The base set of tags that will be applied to resources."
  type        = map(string)
  default     = {}
}
