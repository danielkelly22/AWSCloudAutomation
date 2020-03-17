# Shared providers declared in vpc-shared.tf file

#-----------------------------------------------
# Primary
#-----------------------------------------------
module "transit_tags" {
  providers = { aws = aws.shared }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.1"

  application_name     = var.networking_application_name
  business_unit        = var.networking_business_unit
  environment          = var.shared_vpc_details.primary.environment_affix
  cost_center          = var.networking_cost_center
  application_owner    = var.networking_team_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

module "transit_vpc" {
  source = "./modules/vpc"
  providers = {
    aws        = aws.shared
    aws.shared = aws.shared
  }

  transit_gateway_id                 = module.tgw.tgw_id
  vpc_details                        = var.transit_vpc_details.primary
  skip_gateway_attachment_acceptance = true
  aws_routable_cidr_blocks = {
    shared-services = local.all_cidr_addresses.shared.primary
  }

  tags = module.transit_tags.tags
}

#-----------------------------------------------
# DR
#-----------------------------------------------
module "dr_transit_tags" {
  providers = { aws = aws.shared_dr }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.1"

  application_name     = var.networking_application_name
  business_unit        = var.networking_business_unit
  environment          = var.transit_vpc_details.dr.environment_affix
  cost_center          = var.networking_cost_center
  application_owner    = var.networking_team_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

module "dr_transit_vpc" {
  source = "./modules/vpc"
  providers = {
    aws        = aws.shared_dr
    aws.shared = aws.shared_dr
  }

  transit_gateway_id                 = module.dr_tgw.tgw_id
  vpc_details                        = var.transit_vpc_details.dr
  skip_gateway_attachment_acceptance = true
  aws_routable_cidr_blocks = {
    dr-shared-services = local.all_cidr_addresses.shared.dr
  }

  tags = module.dr_transit_tags.tags
}
