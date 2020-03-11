provider "aws" {
  alias  = "uat"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::213440460626:role/TestRoot"
  }
}

#-----------------------------------------------
# Primary
#-----------------------------------------------
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
