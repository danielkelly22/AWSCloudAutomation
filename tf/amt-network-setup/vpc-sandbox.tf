provider "aws" {
  alias  = "sandbox"
  region = "us-east-1"
  assume_role {
    role_arn = var.organization_accounts.sandbox.assume_role_arn
  }
}

module "sandbox_tags" {
  providers = { aws = aws.sandbox }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.1"

  application_name     = var.networking_application_name
  business_unit        = var.networking_business_unit
  environment          = var.shared_vpc_details.sandbox.environment_affix
  cost_center          = var.networking_cost_center
  application_owner    = var.networking_team_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

module "sandbox_vpc" {
  source = "./modules/vpc"
  providers = {
    aws        = aws.sandbox
    aws.shared = aws.sandbox
  }

  transit_gateway_id                 = module.sandbox_tgw.tgw_id
  vpc_details                        = var.sandbox_vpc_details.primary
  skip_gateway_attachment_acceptance = true
  aws_routable_cidr_blocks = {
    transit = local.all_cidr_addresses.shared.primary
  }

  tags = module.shared_tags.tags
}
