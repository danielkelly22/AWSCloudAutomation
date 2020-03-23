variable "tags" {
  description = "The tags to apply to the resources"
  type        = map(string)
}

variable "transit_gateway_id" {
  description = "(Optional) provide this if there are internet connected subnets."
  type        = string
  default     = ""
}

variable "vpc_defaults" {
  description = "Default settings for the VPC"
  type = object({
    instance_tenancy                 = string
    enable_dns_hostnames             = bool
    enable_dns_support               = bool
    enable_classiclink               = bool
    enable_classiclink_dns_support   = bool
    assign_generated_ipv6_cidr_block = bool
    provision_s3_vpc_endpoint        = bool
  })
  default = {
    instance_tenancy                 = "default"
    enable_dns_hostnames             = true
    enable_dns_support               = true
    enable_classiclink               = false
    enable_classiclink_dns_support   = false
    assign_generated_ipv6_cidr_block = false
    provision_s3_vpc_endpoint        = true
  }
}

variable "vpc_details" {
  description = "The details describing the VPC"
  type = object({
    cidr_block        = string
    environment_affix = string
    subnets = map(object({
      availability_zone = string
      cidr = object({
        newbits = number
        netnum  = number
      })
    }))
    subnet_shares = map(object({
      target_name               = string
      allow_external_principals = bool
      principal                 = string
      subnets = map(object({
        description = string
      }))
    }))
    transited_subnets = list(string)
    public_subnets    = set(string)
    nat_subnets       = map(string)
  })
}

variable "aws_routable_cidr_blocks" {
  description = "The ingress CIDR blocks allowed into the VPC"
  type        = map(string)
}


variable "internet_routable_cidr_blocks" {
  description = "(Optional) The egress CIDR blocks allowed from the VPC. Defaults to '0.0.0.0/0'"
  type        = map(string)
  default     = { zeroes = "0.0.0.0/0" }
}

variable "private_egress_blocks" {
  description = "(Optional) The private IP address ranges that are allowed for egress. Defaults to all RFC1918 private network ranges."
  type        = map(string)
  default = {
    tens            = "10.0.0.0/8",
    one-seventy-two = "172.16.0.0/12",
    one-ninety-two  = "192.168.0.0/16"
  }
}

variable "skip_gateway_attachment_acceptance" {
  description = "Set this to true if the VPC and the transit gateway are in the same account. Defaults to false."
  type        = bool
  default     = false
}

variable "transit_gateway_default_route_table_association" {
  description = "(Optional) See the docs. Defaults to 'false'"
  type        = bool
  default     = false
}

variable "transit_gateway_default_route_table_propagation" {
  description = "(Optional) See the docs. Defaults to 'false'"
  type        = bool
  default     = false
}
