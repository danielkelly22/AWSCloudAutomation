provider "aws" {
  alias  = "dev"
  region = "us-east-1"
  assume_role {
    role_arn = var.organization_accounts.development.assume_role_arn
  }
}

provider "aws" {
  alias  = "dev_dr"
  region = "us-east-2"
  assume_role {
    role_arn = var.organization_accounts.development.assume_role_arn
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

# #-----------------------------------------------
# # DR
# #-----------------------------------------------
# module "dr_dev_tags" {
#   providers = { aws = aws.dev_dr }

#   source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
#   version = ">= 0.2.0"

#   application_name     = "Networking"
#   application_owner    = "amtrustcloudteam@amtrustgroup.com"
#   business_unit        = "tbd"
#   cost_center          = "IT0000"
#   environment          = "development-dr"
#   infrastructure_owner = "amtrustcloudteam@amtrustgroup.com"
# }

# module "dr_dev_vpc" {
#   source = "./modules/vpc"
#   providers = {
#     aws = aws.dev_dr
#   }

#   vpc_details = var.dev_vpc_details.dr

#   tags = module.dr_dev_tags.tags
# }

# module "dr_dev_tgw_setup" {
#   source = "./modules/vpc_routes_and_rules"

#   providers = {
#     aws        = aws.dev_dr
#     aws.shared = aws.shared_dr
#   }

#   environment_affix                 = var.dev_vpc_details.dr.environment_affix
#   subnets                           = module.dr_dev_vpc.transited_subnets
#   vpc_id                            = module.dr_dev_vpc.vpc_id
#   transit_gateway_id                = module.dr_tgw.tgw_id
#   vpn_transit_gateway_attachment_id = "" # todo

#   aws_routable_cidr_blocks = local.common_routes.dr
#   blackhole_cidr_blocks = {
#     prod-primary = local.all_cidr_addresses.production.primary
#     prod-dr      = local.all_cidr_addresses.production.dr
#     uat-primary  = local.all_cidr_addresses.uat.primary
#     uat-dr       = local.all_cidr_addresses.uat.dr
#   }

#   tags = module.dr_dev_tags.tags
# }
