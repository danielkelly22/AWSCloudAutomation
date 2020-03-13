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
module "uat_uat_tags" {
  providers = { aws = aws.uat_dr }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.1"

  application_name     = var.networking_application_name
  business_unit        = var.networking_business_unit
  environment          = "uat" #var.uat_vpc_details.primary.environment_affix
  cost_center          = var.networking_cost_center
  application_owner    = var.networking_team_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
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

#-----------------------------------------------
# DR
#-----------------------------------------------
module "dr_uat_tags" {
  providers = { aws = aws.uat_dr }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.1"

  application_name     = var.networking_application_name
  business_unit        = var.networking_business_unit
  environment          = var.uat_vpc_details.dr.environment_affix
  cost_center          = var.networking_cost_center
  application_owner    = var.networking_team_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
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
