terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket = "amtrust-tf-state"
    key    = "pipelines/landing-zone/terraform.tfstate"
    region = "us-east-1"
  }
}
#-----------------------------------------------
# Set up proviers 
#-----------------------------------------------
provider "aws" {
  region = "us-east-1"
}

locals {
  local_addresses = {
    tens            = "10.0.0.0/8",
    one-seventy-two = "172.16.0.0/12",
    one-ninety-two  = "192.168.0.0/16"
  }
  all_cidr_addresses = {
    shared = {
      primary = var.shared_vpc_cidr
      dr      = var.shared_vpc_details.dr.cidr_block
    }
    transit = {
      primary = var.transit_vpc_cidr
      dr      = var.transit_vpc_details.dr.cidr_block
    }
    production = {
      primary = var.prod_vpc_cidr
      dr      = var.prod_vpc_details.dr.cidr_block
    }
    development = {
      primary = var.dev_vpc_cidr
      dr      = var.dev_vpc_details.dr.cidr_block
    }
    uat = {
      primary = var.uat_vpc_cidr
      dr      = var.uat_vpc_details.dr.cidr_block
    }
  }
  common_routes = {
    primary = {
      shared  = local.all_cidr_addresses.shared.primary
      transit = local.all_cidr_addresses.shared.primary
    }
    dr = {
      shared  = local.all_cidr_addresses.shared.dr
      transit = local.all_cidr_addresses.shared.dr
    }
  }
}
