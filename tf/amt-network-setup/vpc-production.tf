provider "aws" {
  alias  = "prod"
  region = "us-east-1"
  assume_role {
    role_arn = var.organization_accounts.production.assume_role_arn
  }
}
provider "aws" {
  alias  = "prod_dr"
  region = "us-east-2"
  assume_role {
    role_arn = var.organization_accounts.production.assume_role_arn
  }
}

#-----------------------------------------------
# Primary
#-----------------------------------------------
module "prod_tags" {
  providers = { aws = aws.prod }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.1"

  application_name     = var.networking_application_name
  business_unit        = var.networking_business_unit
  environment          = "prod" #var.prod_vpc_details.primary.environment_affix
  cost_center          = var.networking_cost_center
  application_owner    = var.networking_team_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

# module "prod_vpc" {
#   providers = {
#     aws        = aws.prod
#     aws.shared = aws.shared
#   }

#   source = "./modules/vpc"

#   transit_gateway_id = module.transit-gateway.transit_gateway_id
#   vpc_details        = var.prod_vpc_details.primary
#   aws_routable_cidr_blocks = {
#     dr-shared-services = local.all_cidr_addresses.shared.primary
#     dr-transit         = local.all_cidr_addresses.transit.primary
#   }

#   tags = module.prod_tags.tags
# }

#-----------------------------------------------
# DR
#-----------------------------------------------
module "dr_prod_tags" {
  providers = { aws = aws.prod_dr }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.1"

  application_name     = var.networking_application_name
  business_unit        = var.networking_business_unit
  environment          = var.prod_vpc_details.dr.environment_affix
  cost_center          = var.networking_cost_center
  application_owner    = var.networking_team_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

module "dr_prod_vpc" {
  providers = {
    aws        = aws.prod_dr
    aws.shared = aws.shared_dr
  }

  source = "./modules/vpc"

  transit_gateway_id = module.dr_tgw.tgw_id
  vpc_details        = var.prod_vpc_details.dr
  aws_routable_cidr_blocks = {
    dr-shared-services = local.all_cidr_addresses.shared.dr
    dr-transit         = local.all_cidr_addresses.transit.dr
  }

  tags = module.dr_prod_tags.tags
}
