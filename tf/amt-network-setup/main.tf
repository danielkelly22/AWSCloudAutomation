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
  common_routes = {
    dr-shared  = var.shared_vpc_details.dr.cidr_block
    dr-transit = var.transit_vpc_details.dr.cidr_block
  }
  non_prod_routes = {}
  production_routes = {
    dr-production = var.prod_vpc_details.dr.cidr_block
  }
  local_addresses = {
    tens            = "10.0.0.0/8",
    one-seventy-two = "172.16.0.0/12",
    one-ninety-two  = "192.168.0.0/16"
  }
}
