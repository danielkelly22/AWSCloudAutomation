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
  version = ">= 0.3.1"

  application_name     = var.networking_application_name
  business_unit        = var.networking_business_unit
  environment          = "shared" #var.shared_vpc_details.primary.environment_affix
  cost_center          = var.networking_cost_center
  application_owner    = var.networking_team_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
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
# DR
#-----------------------------------------------
module "dr_shared_tags" {
  providers = { aws = aws.shared_dr }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.1"

  application_name     = var.networking_application_name
  business_unit        = var.networking_business_unit
  environment          = var.shared_vpc_details.dr.environment_affix
  cost_center          = var.networking_cost_center
  application_owner    = var.networking_team_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

module "dr_shared_vpc" {
  source = "./modules/vpc"
  providers = {
    aws        = aws.shared_dr
    aws.shared = aws.shared_dr
  }

  transit_gateway_id                 = module.dr_tgw.tgw_id
  vpc_details                        = var.shared_vpc_details.dr
  skip_gateway_attachment_acceptance = true
  aws_routable_cidr_blocks = {
    dr-shared-services = local.all_cidr_addresses.shared.dr
    dr-transit         = local.all_cidr_addresses.transit.dr
  }

  tags = module.dr_shared_tags.tags
}
