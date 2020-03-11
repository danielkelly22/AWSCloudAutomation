provider "aws" {
  alias  = "dev"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::366159711973:role/DevRoot"
  }
}

#-----------------------------------------------
# Primary
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
