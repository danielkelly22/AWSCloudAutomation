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
module "dev_tags" {
  providers = { aws = aws.prod }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.1"

  application_name     = var.networking_application_name
  business_unit        = var.networking_business_unit
  environment          = var.dev_vpc_details.primary.environment_affix
  cost_center          = var.networking_cost_center
  application_owner    = var.networking_team_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

# module "dev_vpc" {
#   source = "./modules/vpc"
#   providers = {
#     aws        = aws.dev
#     aws.shared = aws.shared
#   }

#   transit_gateway_id = module.transit-gateway.transit_gateway_id
#   vpc_details        = var.dev_vpc_details.primary
#   aws_routable_cidr_blocks = {
#     dr-shared-services = local.all_cidr_addresses.shared.primary
#     dr-transit         = local.all_cidr_addresses.transit.primary
#   }

#   tags = module.dev_tags.tags
# }

#-----------------------------------------------
# DR
#-----------------------------------------------
module "dr_dev_tags" {
  providers = { aws = aws.dev_dr }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.1"

  application_name     = var.networking_application_name
  business_unit        = var.networking_business_unit
  environment          = var.dev_vpc_details.dr.environment_affix
  cost_center          = var.networking_cost_center
  application_owner    = var.networking_team_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

module "dr_dev_vpc" {
  source = "./modules/vpc"
  providers = {
    aws        = aws.dev_dr
    aws.shared = aws.shared_dr
  }

  transit_gateway_id = module.dr_tgw.tgw_id
  vpc_details        = var.dev_vpc_details.dr
  aws_routable_cidr_blocks = {
    dr-shared-services = local.all_cidr_addresses.shared.dr
    dr-transit         = local.all_cidr_addresses.transit.dr
  }

  tags = module.dr_dev_tags.tags
}
