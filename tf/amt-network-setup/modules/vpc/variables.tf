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
  })
  default = {
    instance_tenancy                 = "default"
    enable_dns_hostnames             = true
    enable_dns_support               = true
    enable_classiclink               = false
    enable_classiclink_dns_support   = false
    assign_generated_ipv6_cidr_block = false
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
    transited_subnets          = list(string)
    internet_connected_subnets = map(string)
  })
}

variable "internet_egress_routes" {
  description = ""
  type        = map(string)
  default     = { zeroes = "0.0.0.0/0" }
}

variable "private_egress_routes" {
  description = ""
  type        = map(string)
  default = {
    tens            = "10.0.0.0/8",
    one-seventy-two = "172.16.0.0/12",
    one-ninety-two  = "192.168.0.0/16"
  }
}

