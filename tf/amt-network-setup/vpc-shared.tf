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
#-----------------------------------------------
# Sandbox
#-----------------------------------------------
module "sandbox_shared_tags" {
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

module "sandbox_shared_vpc" {
  source = "./modules/vpc"
  providers = {
    aws        = aws.sandbox
    aws.shared = aws.sandbox
  }

  transit_gateway_id                 = module.sandbox_tgw.tgw_id
  vpc_details                        = var.shared_vpc_details.sandbox
  skip_gateway_attachment_acceptance = true
  aws_routable_cidr_blocks = {
    sandbox-transit = local.all_cidr_addresses.transit.sandbox
  }

  tags = module.sandbox_shared_tags.tags
}


#-----------------------------------------------
# Shared Cloudendure Replication
#-----------------------------------------------
module "shared_cloudendure_replication_tags" {
  providers = { aws = aws.shared }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.1"

  application_name     = var.networking_application_name
  business_unit        = var.networking_business_unit
  environment          = var.shared_vpc_details.cloudendure_replication.environment_affix
  cost_center          = var.networking_cost_center
  application_owner    = var.networking_team_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

module "shared_cloudendure_replication_vpc" {
  source = "./modules/vpc"
  providers = {
    aws = aws.shared
    aws.shared = aws.shared
  }

  transit_gateway_id = module.tgw.tgw_id
  vpc_details = var.shared_vpc_details.cloudendure_replication
  skip_gateway_attachment_acceptance = true

  # TODO: this is probably wrong
  aws_routable_cidr_blocks = {
    transit = local.all_cidr_addresses.transit.primary
  }

  tags = merge(
    module.shared_cloudendure_replication_tags.tags
  )
}


#-----------------------------------------------
# Shared drtest
#-----------------------------------------------
module "shared_drtest_tags" {
  providers = { aws = aws.shared }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.1"

  application_name     = var.networking_application_name
  business_unit        = var.networking_business_unit
  environment          = var.shared_vpc_details.drtest.environment_affix
  cost_center          = var.networking_cost_center
  application_owner    = var.networking_team_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

# TODO: the drtest jump host subnet (only) needs a VPCE for S3 for packages like mremoteng.
module "shared_drtest_vpc" {
  source = "./modules/vpc"
  providers = {
    aws        = aws.shared
    aws.shared = aws.shared
  }

  transit_gateway_id                 = module.tgw.tgw_id
  vpc_details                        = var.shared_vpc_details.drtest

  # The default gateway for this VPC needs locked-down.
  # It is handled in ./vpc-shared-drtest.tf
  skip_default_sg_config             = true
  skip_gateway_attachment_acceptance = true

  # The only default we need is provision_s3_vpc_endpoint,
  # but they all must be specified since it's a map.
  vpc_defaults = {
    instance_tenancy                 = "default"
    enable_dns_hostnames             = true
    enable_dns_support               = true
    enable_classiclink               = false
    enable_classiclink_dns_support   = false
    assign_generated_ipv6_cidr_block = false
    provision_s3_vpc_endpoint        = false
  }

  aws_routable_cidr_blocks = {}

  tags = module.shared_drtest_tags.tags
}
