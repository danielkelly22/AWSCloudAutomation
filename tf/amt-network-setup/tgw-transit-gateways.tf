#-----------------------------------------------
# Primary
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
    aws.shared = aws.shared
    aws.dev    = aws.dev
    aws.prod   = aws.prod
    aws.uat    = aws.uat
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
# DR
#-----------------------------------------------
# module "dr_tgw_tags" {
#   providers = { aws = aws.shared_dr }

#   source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
#   version = ">= 0.2.0"

#   application_name     = "Networking"
#   application_owner    = "amtrustcloudteam@amtrustgroup.com"
#   business_unit        = "tbd"
#   cost_center          = "IT0000"
#   environment          = "dr"
#   infrastructure_owner = "amtrustcloudteam@amtrustgroup.com"
# }

# module "dr_tgw" {
#   providers = { aws = aws.shared_dr }

#   source = "./modules/transit_gateway"

#   tags = module.dr_tgw_tags.tags
# }
