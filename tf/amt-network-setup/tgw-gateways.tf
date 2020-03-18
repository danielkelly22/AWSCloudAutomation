#-----------------------------------------------
# Primary
#-----------------------------------------------
module "tgw_tags" {
  providers = { aws = aws.shared }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.1"

  application_name     = var.networking_application_name
  business_unit        = var.networking_business_unit
  environment          = "transit"
  cost_center          = var.networking_cost_center
  application_owner    = var.networking_team_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

module "tgw" {
  providers = { aws = aws.shared }

  source = "./modules/transit_gateway"

  description = "Transit Transit Gateway"

  tags = module.tgw_tags.tags
}

#-----------------------------------------------
# DR
#-----------------------------------------------
module "dr_tgw_tags" {
  providers = { aws = aws.shared_dr }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.1"

  application_name     = var.networking_application_name
  business_unit        = var.networking_business_unit
  environment          = "dr_transit"
  cost_center          = var.networking_cost_center
  application_owner    = var.networking_team_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

module "dr_tgw" {
  providers = { aws = aws.shared_dr }

  source = "./modules/transit_gateway"

  tags = module.dr_tgw_tags.tags
}
