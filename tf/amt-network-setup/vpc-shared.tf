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
  environment          = var.shared_vpc_details.primary.environment_affix
  cost_center          = var.networking_cost_center
  application_owner    = var.networking_team_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

module "shared_vpc" {
  source = "./modules/vpc"
  providers = {
    aws        = aws.shared
    aws.shared = aws.shared
  }

  transit_gateway_id                 = module.tgw.tgw_id
  vpc_details                        = var.shared_vpc_details.primary
  skip_gateway_attachment_acceptance = true
  aws_routable_cidr_blocks = {
    transit = local.all_cidr_addresses.transit.primary
  }

  tags = module.shared_tags.tags
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
    dr-transit = local.all_cidr_addresses.transit.dr
  }

  tags = module.dr_shared_tags.tags
}

# output "s3_endpoint" {
#   value = module.shared_vpc.s3_endpoint
# }

# output "public_route_flat" {
#   value = module.shared_vpc.public_route_flat
# }

# output "any_public_egress" {
#   value = module.shared_vpc.any_public_egress
# }
