variable "networking_business_unit" {
  description = "The business unit for networking"
  type        = string
  default     = "tbd"
}

variable "networking_team_email" {
  description = "The email of the network team"
  type        = string
  default     = "tbd"
}

variable "networking_cost_center" {
  description = "The cost center for the cloud architecture department"
  type        = string
  default     = "IT0000"
}

variable "networking_application_name" {
  description = "The application name for cloud governance resources"
  type        = string
  default     = "Networking"
}

variable "cloud_governance_email" {
  description = "The email of the cloud governance department"
  type        = string
  default     = "amtrustcloudteam@amtrustgroup.com"
}

variable "terraform_workspace" {
  description = "The name of the terraform workspace that manages the resources"
  type        = string
  default     = "amt-network-setup"
}

variable "dev_vpc_cidr" {
  type    = string
  default = "10.98.16.0/20"
}

variable "uat_vpc_cidr" {
  type    = string
  default = "10.98.32.0/20"
}

variable "prod_vpc_cidr" {
  type    = string
  default = "10.98.48.0/20"
}

variable "shared_vpc_cidr" {
  type    = string
  default = "10.98.0.0/21"
}

variable "transit_vpc_cidr" {
  type    = string
  default = "10.98.8.0/21"
}

variable "sandbox_vpc_cidr" {
  type    = string
  default = "10.201.152.0/22"
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
    development = {
      account_number  = "366159711973"
      root_role       = "DevRoot"
      assume_role_arn = "arn:aws:iam::366159711973:role/DevRoot"
    }
    uat = {
      account_number  = "213440460626"
      root_role       = "TestRoot"
      assume_role_arn = "arn:aws:iam::213440460626:role/TestRoot"
    }
    sandbox = {
      account_number  = "964926329483"
      root_role       = "SandboxRoot"
      assume_role_arn = "arn:aws:iam::964926329483:role/SandboxRoot"
    }
  }
}

variable "shared_vpc_details" {
  description = "The VPC details for shared VPCs"
  type = object({
    primary = any
    dr      = any
    sandbox = any
  })
}

variable "transit_vpc_details" {
  description = "The VPC details for transit VPCs"
  type = object({
    primary = any
    dr      = any
    sandbox = any
  })
}

variable "dev_vpc_details" {
  description = "The VPC details for devlopment VPCs"
  type = object({
    primary = any
    dr      = any
  })
}

variable "uat_vpc_details" {
  description = "The VPC details for UAT VPCs"
  type = object(
    {
      primary = any
      dr      = any
  })
}

variable "prod_vpc_details" {
  description = "The VPC details for production VPCs"
  type = object({
    primary = any
    dr      = any
  })
}

variable "sandbox_vpc_details" {
  description = "The VPC details for shared VPCs"
  type = object({
    primary = any
  })
}

variable "dc_subnets" {
  type = map
  default = {
    subnet_a_id = "subnet-0d854a74a97f6e236"
    subnet_b_id = "subnet-0018c69704ac4e06d"
  }
}
variable "dc_ami_id" { default = "ami-047c2af78a8dc4a91" }

variable "dc_instance_size" { default = "t2.large" }

variable "palo_ami" {
  type    = string
  default = "ami-050725600cf371a1c"
}

variable "palo_key_name" {
  type    = string
  default = "paloalto-vmseries"
}

