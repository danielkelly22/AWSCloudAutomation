provider "aws" {
  alias  = "shared"
  region = "us-east-1"
  assume_role {
    role_arn = var.organization_accounts.shared.assume_role_arn
  }
}
provider "aws" {
  alias  = "shared_dr"
  region = "us-east-2"
  assume_role {
    role_arn = var.organization_accounts.shared.assume_role_arn
  }
}

#-----------------------------------------------
# Primary
#-----------------------------------------------
module "shared_tags" {
  providers = { aws = aws.shared }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.2.0"

  application_name     = "Networking"
  application_owner    = "amtrustcloudteam@amtrustgroup.com"
  business_unit        = "tbd"
  cost_center          = "IT0000"
  environment          = "production"
  infrastructure_owner = "amtrustcloudteam@amtrustgroup.com"
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

#-----------------------------------------------
# DR
#-----------------------------------------------
# module "dr_shared_tags" {
#   providers = { aws = aws.shared_dr }

#   source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
#   version = ">= 0.2.0"

#   application_name     = "Networking"
#   application_owner    = "amtrustcloudteam@amtrustgroup.com"
#   business_unit        = "tbd"
#   cost_center          = "IT0000"
#   environment          = "production-dr"
#   infrastructure_owner = "amtrustcloudteam@amtrustgroup.com"
# }

# module "dr_shared_vpc" {
#   source = "./modules/vpc"
#   providers = {
#     aws = aws.shared_dr
#   }

#   vpc_details = var.vpc_details.shared_dr

#   tags = module.dr_shared_tags.tags
# }

# # # ☑ transit gateway 
# # # ☑ gateway attachments
# # # ☐ routes
# # # ☐ security group
# module "dr_shared_tgw_setup" {
#   source = "./modules/transit_gateway_setup"

#   providers = {
#     aws        = aws.shared_dr
#     aws.shared = aws.shared_dr
#   }

#   environment_affix                  = var.vpc_details.shared_dr.environment_affix
#   subnets                            = module.dr_shared_vpc.transited_subnets
#   vpc_id                             = module.dr_shared_vpc.vpc_id
#   transit_gateway_id                 = module.dr_tgw.tgw_id
#   vpn_transit_gateway_attachment_id  = "" # todo
#   skip_gateway_attachment_acceptance = true

#   tags = module.dr_shared_tags.tags
# }
