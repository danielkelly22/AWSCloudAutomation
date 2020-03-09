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

