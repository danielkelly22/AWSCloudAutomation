provider "aws" {
  alias  = "uat"
  region = "us-east-1"
  assume_role {
    role_arn = var.organization_accounts.uat.assume_role_arn
  }
}

provider "aws" {
  alias  = "uat_dr"
  region = "us-east-2"
  assume_role {
    role_arn = var.organization_accounts.uat.assume_role_arn
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

#-----------------------------------------------
# DR
#-----------------------------------------------
module "dr_uat_tags" {
  providers = { aws = aws.uat_dr }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.2.0"

  application_name     = "Networking"
  application_owner    = "amtrustcloudteam@amtrustgroup.com"
  business_unit        = "tbd"
  cost_center          = "IT0000"
  environment          = "uat-dr"
  infrastructure_owner = "amtrustcloudteam@amtrustgroup.com"
}

module "dr_uat_vpc" {
  source = "./modules/vpc"
  providers = {
    aws        = aws.uat_dr
    aws.shared = aws.shared_dr
  }

  transit_gateway_id = module.dr_tgw.tgw_id
  vpc_details        = var.uat_vpc_details.dr
  aws_routable_cidr_blocks = {
    dr-shared-services = local.all_cidr_addresses.shared.dr
    dr-transit         = local.all_cidr_addresses.transit.dr
  }

  tags = module.dr_uat_tags.tags
}
