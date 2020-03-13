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
module "production_tags" {
  providers = { aws = aws.prod }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.2.0"

  application_name     = "Networking"
  application_owner    = "amtrustcloudteam@amtrustgroup.com"
  business_unit        = "tbd"
  cost_center          = "IT0000"
  environment          = "production"
  infrastructure_owner = "amtrustcloudteam@amtrustgroup.com"
}

module "prodVpc" {
  source = "./modules/prodVpc"
  providers = {
    aws = aws.prod
  }
  vpc_cidr           = var.prod_vpc_cidr
  subnet_names       = var.prod_subnet_names
  subnet_ranges      = var.prod_subnet_ranges
  availability_zones = var.prod_subnet_azs
  transit_gateway_id = module.transit-gateway.transit_gateway_id
  env_name           = "Prod"
}

#-----------------------------------------------
# DR
#-----------------------------------------------
module "dr_prod_tags" {
  providers = { aws = aws.prod_dr }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.2.0"

  application_name     = "Networking"
  application_owner    = "amtrustcloudteam@amtrustgroup.com"
  business_unit        = "tbd"
  cost_center          = "IT0000"
  environment          = "production-dr"
  infrastructure_owner = "amtrustcloudteam@amtrustgroup.com"
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
