variable "dev_vpc_cidr" {
  type    = string
  default = "10.98.16.0/20"
}
variable "dev_subnet_ranges" {
  type = list(string)
  default = [
    "10.98.16.0/23",
    "10.98.18.0/23",
    "10.98.20.0/23",
    "10.98.22.0/24",
    "10.98.23.0/24",
    "10.98.24.0/23",
    "10.98.26.0/23",
    "10.98.28.0/23",
  ]
}
variable "dev_subnet_names" {
  type = list(string)
  default = [
    "DevWebSubnetA",
    "DevAppSubnetA",
    "DevDataSubnetA",
    "DevOmniSubnetA",
    "DevOmniSubnetB",
    "DevWebSubnetB",
    "DevAppSubnetB",
    "DevDataSubnetB",
  ]
}
variable "dev_subnet_azs" {
  type = list(string)
  default = [
    "us-east-1a",
    "us-east-1a",
    "us-east-1a",
    "us-east-1a",
    "us-east-1b",
    "us-east-1b",
    "us-east-1b",
    "us-east-1b",
  ]
}

variable "uat_vpc_cidr" {
  type    = string
  default = "10.98.32.0/20"
}
variable "uat_subnet_ranges" {
  type = list(string)
  default = [
    "10.98.32.0/23",
    "10.98.34.0/23",
    "10.98.36.0/23",
    "10.98.40.0/23",
    "10.98.42.0/23",
    "10.98.44.0/23",
  ]
}
variable "uat_subnet_names" {
  type = list(string)
  default = [
    "UatWebSubnetA",
    "UatAppSubnetA",
    "UatDataSubnetA",
    "UatWebSubnetB",
    "UatAppSubnetB",
    "UatDataSubnetB"
  ]
}
variable "uat_subnet_azs" {
  type = list(string)
  default = [
    "us-east-1a",
    "us-east-1a",
    "us-east-1a",
    "us-east-1b",
    "us-east-1b",
    "us-east-1b",
  ]
}


variable "prod_vpc_cidr" {
  type    = string
  default = "10.98.48.0/20"
}
variable "prod_subnet_ranges" {
  type = list(string)
  default = [
    "10.98.48.0/23",
    "10.98.50.0/23",
    "10.98.52.0/23",
    "10.98.54.0/24",
    "10.98.55.0/24",
    "10.98.56.0/23",
    "10.98.58.0/23",
    "10.98.60.0/23",
  ]
}
variable "prod_subnet_names" {
  type = list(string)
  default = [
    "ProdWebSubnetA",
    "ProdAppSubnetA",
    "ProdDataSubnetA",
    "ProdOmniSubnetA",
    "ProdOmniSubnetB",
    "ProdWebSubnetB",
    "ProdAppSubnetB",
    "ProdDataSubnetB",
  ]
}
variable "prod_subnet_azs" {
  type = list(string)
  default = [
    "us-east-1a",
    "us-east-1a",
    "us-east-1a",
    "us-east-1a",
    "us-east-1b",
    "us-east-1b",
    "us-east-1b",
    "us-east-1b",
  ]
}

variable "shared_vpc_cidr" {
  type    = string
  default = "10.98.0.0/21"
}
variable "shared_subnet_ranges" {
  type = list(string)
  default = [
    "10.98.0.0/23",
    "10.98.2.0/23",
    "10.98.4.0/24",
    "10.98.5.0/24",
    "10.98.6.0/24",
    "10.98.7.0/24",
  ]
}
variable "shared_subnet_names" {
  type = list(string)
  default = [
    "SharedServicesCoreSubnetA",
    "SharedServicesCoreSubnetB",
    "SharedServicesJumpSubnetA",
    "SharedServicesJumpSubnetB",
    "SharedServicesTrainerSubnetA",
    "SharedServicesTrainerSubnetB"
  ]
}

variable "shared_subnet_azs" {
  type = list(string)
  default = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1a",
    "us-east-1b",
    "us-east-1a",
    "us-east-1b",
  ]
}



variable "transit_vpc_cidr" {
  type    = string
  default = "10.98.8.0/21"
}
variable "transit_subnet_names" {
  type = list(string)
  default = [
    "TransitPublicSubnetA",
    "TransitPrivateSubnetA",
    "TransitMgmtSubnetA"
  ]
}
variable "transit_subnet_ranges" {
  type = list(string)
  default = [
    "10.98.8.0/24",
    "10.98.9.0/24",
    "10.98.10.0/26"
  ]
}
variable "transit_subnet_azs" {
  type = list(string)
  default = [
    "us-east-1a",
    "us-east-1a",
    "us-east-1a"
  ]
}

variable "organization_accounts" {
  description = "The organization account access details."
  type = map(object({
    account_number  = string
    root_role       = string
    assume_role_arn = string
  }))
  default = {
    shared = {
      account_number  = "207476187760"
      root_role       = "SharedSvcRoot"
      assume_role_arn = "arn:aws:iam::207476187760:role/SharedSvcRoot"
    }
    production = {
      account_number  = "347306377087"
      root_role       = "ProductionRoot"
      assume_role_arn = "arn:aws:iam::347306377087:role/ProductionRoot"
    }
  }
}

variable "shared_vpc_details" {
  description = "The VPC details for shared VPCs"
  type        = object({ dr = any })
}

variable "transit_vpc_details" {
  description = "The VPC details for transit VPCs"
  type        = object({ dr = any })
}

variable "dev_vpc_details" {
  description = "The VPC details for devlopment VPCs"
  type        = object({ dr = any })
}

variable "prod_vpc_details" {
  description = "The VPC details for production VPCs"
  type        = object({ dr = any })
  # type = object({
  #   dr = object({
  #     cidr_block        = string
  #     environment_affix = string
  #     subnets = map(object({
  #       availability_zone = string
  #       cidr = object({
  #         newbits = number
  #         netnum  = number
  #       })
  #     }))
  #     subnet_shares = map(object({
  #       target_name               = string
  #       allow_external_principals = bool
  #       principal                 = string
  #       subnets = map(object({
  #         description = string
  #       }))
  #     }))
  #     transited_subnets = list(string)
  #   })
  # })
}
