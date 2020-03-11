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

variable "vpc_details" {
  default = {
    prod_dr = {
      cidr_block        = "10.100.0.0/20"
      environment_affix = "dr-prod"
      subnets = {
        amt-dr-prod-web-subnet-a = {
          availability_zone = "us-east-2a"
          cidr = { # cidrsubnet("10.100.0.0/20", 3, 0) = 10.100.0.0/23
            newbits = 3
            netnum  = 0
          }
        }
        amt-dr-prod-app-subnet-a = {
          availability_zone = "us-east-2a"
          cidr = { # cidrsubnet("10.100.0.0/20", 3, 1) = 10.100.2.0/23
            newbits = 3
            netnum  = 1
          }
        }
        amt-dr-prod-data-subnet-a = {
          availability_zone = "us-east-2a"
          cidr = { # cidrsubnet("10.100.0.0/20", 3, 2) = 10.100.4.0/23
            newbits = 3
            netnum  = 2
          }
        }
        amt-dr-prod-omnius-subnet-a = {
          availability_zone = "us-east-2a"
          cidr = { # cidrsubnet("10.100.0.0/20", 4, 6) = 10.100.6.0/24
            newbits = 4
            netnum  = 6
          }
        }
        amt-dr-prod-omnius-subnet-b = {
          availability_zone = "us-east-2b"
          cidr = { # cidrsubnet("10.100.0.0/20", 4, 7) = 10.100.7.0/24
            newbits = 4
            netnum  = 7
          }
        }
        amt-dr-prod-web-subnet-b = {
          availability_zone = "us-east-2b"
          cidr = { # cidrsubnet("10.100.0.0/20", 3, 4) = 10.100.8.0/23
            newbits = 3
            netnum  = 4
          }
        }
        amt-dr-prod-app-subnet-b = {
          availability_zone = "us-east-2b"
          cidr = { # cidrsubnet("10.100.0.0/20", 3, 5) = 10.100.10.0/23
            newbits = 3
            netnum  = 5
          }
        }
        amt-dr-prod-data-subnet-b = {
          availability_zone = "us-east-2b"
          cidr = { # cidrsubnet("10.100.0.0/20", 3, 6) = 10.100.12.0/23
            newbits = 3
            netnum  = 6
          }
        }
      }
      subnet_shares = {
        omnius = {
          target_name               = "omnius_prod"
          allow_external_principals = false
          principal                 = "675938983696"
          subnets = {
            amt-dr-prod-omnius-subnet-a = {
              description = "Subnet zone A for the omni:us application"
            }
            amt-dr-prod-omnius-subnet-b = {
              description = "Subnet zone B for the omni:us application"
            }
          }
        }
      }
      transited_subnets = [
        "amt-dr-prod-app-subnet-a",
        "amt-dr-prod-app-subnet-b"
      ]
    }


    shared_dr = {
      cidr_block        = "10.200.0.0/20"
      environment_affix = "dr-shared"
      subnets = {
        amt-dr-shared-core-subnet-a = {
          availability_zone = "us-east-2a"
          cidr = { # cidrsubnet("10.200.0.0/20", 3, 0) = 10.200.0.0/23
            newbits = 3
            netnum  = 0
          }
        }
        amt-dr-shared-core-subnet-b = {
          availability_zone = "us-east-2b"
          cidr = { # cidrsubnet("10.200.0.0/20", 3, 1) = 10.200.2.0/23
            newbits = 3
            netnum  = 1
          }
        }
        amt-dr-shared-jump-subnet-a = {
          availability_zone = "us-east-2a"
          cidr = { # cidrsubnet("10.200.0.0/20", 4, 4) = 10.200.4.0/23
            newbits = 3
            netnum  = 2
          }
        }
        amt-dr-shared-jump-subnet-b = {
          availability_zone = "us-east-2b"
          cidr = { # cidrsubnet("10.200.0.0/20", 4, 5) = 10.200.5.0/24
            newbits = 4
            netnum  = 6
          }
        }
        amt-dr-shared-trainer-subnet-a = {
          availability_zone = "us-east-2a"
          cidr = { # cidrsubnet("10.200.0.0/20", 4, 6) = 10.200.6.0/24
            newbits = 4
            netnum  = 7
          }
        }
        amt-dr-shared-trainer-subnet-b = {
          availability_zone = "us-east-2b"
          cidr = { # cidrsubnet("10.200.0.0/20", 4, 7) = 10.100.7.0/23
            newbits = 3
            netnum  = 4
          }
        }
      }
      subnet_shares = {
        omnius = {
          target_name               = "omnius_nonprod"
          allow_external_principals = false
          principal                 = "421354678477"
          subnets = {
            amt-dr-shared-trainer-subnet-a = {
              description = "Subnet zone A for the omni:us trainer environment"
            }
            amt-dr-shared-trainer-subnet-b = {
              description = "Subnet zone B for the omni:us trainer environment"
            }
          }
        }
      }
      transited_subnets = [
        "amt-dr-shared-core-subnet-a",
        "amt-dr-shared-core-subnet-b"
      ]
    }

  }
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
