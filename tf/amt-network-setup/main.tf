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
provider "aws" {
  alias  = "sandbox"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::964926329483:role/SandboxRoot"
  }
}
provider "aws" {
  alias  = "dev"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::366159711973:role/DevRoot"
  }
}
provider "aws" {
  alias  = "uat"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::213440460626:role/TestRoot"
  }
}
provider "aws" {
  alias  = "shared"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::207476187760:role/SharedSvcRoot"
  }
}
provider "aws" {
  alias  = "prod"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::347306377087:role/ProductionRoot"
  }
}
provider "aws" {
  alias  = "omni-prod"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::675938983696:role/OmniusProdRoot"
  }
}
provider "aws" {
  alias  = "omni-nonprod"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::421354678477:role/OmniusNonProdRoot"
  }
}

#-----------------------------------------------
# Set up VPCs 
#-----------------------------------------------

module "devVpc" {
  source = "./modules/devVpc"
  providers = {
    aws = aws.dev
  }
  vpc_cidr           = var.dev_vpc_cidr
  subnet_names       = var.dev_subnet_names
  subnet_ranges      = var.dev_subnet_ranges
  availability_zones = var.dev_subnet_azs
  transit_gateway_id = module.transit-gateway.transit_gateway_id
  env_name           = "Dev"
}

module "uatVpc" {
  source = "./modules/uatVpc"
  providers = {
    aws = aws.uat
  }
  vpc_cidr           = var.uat_vpc_cidr
  subnet_names       = var.uat_subnet_names
  subnet_ranges      = var.uat_subnet_ranges
  availability_zones = var.uat_subnet_azs
  transit_gateway_id = module.transit-gateway.transit_gateway_id
  env_name           = "Uat"
}

module "prodVpc" {
  source = "./modules/prodVpc"
  providers = {
    aws = aws.prod
  }
  vpc_cidr           = var.prod_vpc_cidr
  subnet_names       = var.prod_subnet_names
  subnet_ranges      = var.prod_subnet_ranges
  availability_zones = var.prod_subnet_azs
  transit_gateway_id = module.transit-gateway.transit_gateway_id
  env_name           = "Prod"
}

module "transitVpc" {
  source = "./modules/transitVpc"
  providers = {
    aws = aws.shared
  }
  vpc_cidr           = var.transit_vpc_cidr
  subnet_names       = var.transit_subnet_names
  subnet_ranges      = var.transit_subnet_ranges
  availability_zones = var.transit_subnet_azs
  transit_gateway_id = module.transit-gateway.transit_gateway_id
  env_name           = "TransitVPC"
}

module "sharedVpc" {
  source = "./modules/sharedVpc"
  providers = {
    aws = aws.shared
  }
  vpc_cidr           = var.shared_vpc_cidr
  subnet_names       = var.shared_subnet_names
  subnet_ranges      = var.shared_subnet_ranges
  availability_zones = var.shared_subnet_azs
  transit_gateway_id = module.transit-gateway.transit_gateway_id
  env_name           = "SharedServices"
}

#-----------------------------------------------
# Set up Transit Gateway
#-----------------------------------------------
data "aws_subnet" "prod_az1" {
  provider   = aws.prod
  cidr_block = var.prod_subnet_ranges[1]
}
data "aws_subnet" "prod_az2" {
  provider   = aws.prod
  cidr_block = var.prod_subnet_ranges[6]
}
data "aws_subnet" "uat_az1" {
  provider   = aws.uat
  cidr_block = var.uat_subnet_ranges[1]
}
data "aws_subnet" "uat_az2" {
  provider   = aws.uat
  cidr_block = var.uat_subnet_ranges[4]
}
data "aws_subnet" "dev_az1" {
  provider   = aws.dev
  cidr_block = var.dev_subnet_ranges[1]
}
data "aws_subnet" "dev_az2" {
  provider   = aws.dev
  cidr_block = var.dev_subnet_ranges[6]
}
data "aws_subnet" "transit_az1" {
  provider   = aws.shared
  cidr_block = var.transit_subnet_ranges[1]
}
data "aws_subnet" "shared_az1" {
  provider   = aws.shared
  cidr_block = var.shared_subnet_ranges[0]
}
data "aws_subnet" "shared_az2" {
  provider   = aws.shared
  cidr_block = var.shared_subnet_ranges[1]
}

module "transit-gateway" {
  source = "./modules/transitGateway"
  providers = {
    aws.shared  = aws.shared
    aws.dev     = aws.dev
    aws.prod    = aws.prod
    aws.uat     = aws.uat
    aws.sandbox = aws.sandbox
  }
  dev_cidr           = var.dev_vpc_cidr
  uat_cidr           = var.uat_vpc_cidr
  prod_cidr          = var.prod_vpc_cidr
  shared_cidr        = var.shared_vpc_cidr
  transit_cidr       = var.transit_vpc_cidr
  vpc_ids            = [module.prodVpc.vpc_id, module.uatVpc.vpc_id, module.devVpc.vpc_id, module.transitVpc.vpc_id, module.sharedVpc.vpc_id]
  prod_subnet_ids    = [data.aws_subnet.prod_az1.id, data.aws_subnet.prod_az2.id]
  uat_subnet_ids     = [data.aws_subnet.uat_az1.id, data.aws_subnet.uat_az2.id]
  dev_subnet_ids     = [data.aws_subnet.dev_az1.id, data.aws_subnet.dev_az2.id]
  transit_subnet_ids = [data.aws_subnet.transit_az1.id]
  shared_subnet_ids  = [data.aws_subnet.shared_az1.id, data.aws_subnet.shared_az2.id]
  vpn_connection_id  = module.mainVPN.vpn_connection_id
  env_name           = "Transit"
}
#-----------------------------------------------
# Set up VPN Connections
#-----------------------------------------------
module "mainVPN" {
  source = "./modules/vpn"
  providers = {
    aws = aws.shared
  }
  transit_gateway_id = module.transit-gateway.transit_gateway_id
}
