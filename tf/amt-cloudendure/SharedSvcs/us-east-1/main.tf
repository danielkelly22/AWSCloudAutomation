terraform {
  required_version = ">= 0.12"
  backend "remote" {
    hostname     = "tfe.amtrustgroup.com"
    organization = "AmTrust"

    workspaces {
      name = "amt-cloudendure-sharedsvcs-ue1"
    }
  }
}

locals {
  aws_account_id = var.organization_accounts.shared.account_number
  aws_region = "us-east-1"
  cloudendure_iam_user_name = "amt-sharedsvcs-cloudendure"
  cloudendure_replication_vpc_name = "amt-shared-cloudendure_replication-vpc"
  environment_affix = "shared-cloudendure-replication"
  terraform_workspace = "amt-cloudendure-sharedsvcs-ue1"
}

module "shared_cloudendure_replication_tags" {
  providers = { aws = aws.shared }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.1"

  application_name     = var.networking_application_name
  business_unit        = var.networking_business_unit
  environment          = var.environment_affix
  cost_center          = var.networking_cost_center
  application_owner    = var.networking_team_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = local.terraform_workspace
}

data "aws_vpc" "cloudendure_replication_vpc" {
  provider = aws.shared
  tags = {
    Name = local.cloudendure_replication_vpc_name
  }
}

module "shared_cloudendure_replication_networking" {
  source = "../../modules/cloudendure_networking"
  providers = {
    aws        = aws.shared
    aws.shared = aws.shared
  }

  environment_affix              = local.environment_affix
  cloudendure_replication_vpc_id = data.aws_vpc.cloudendure_replication_vpc.id
  tags                           = module.shared_cloudendure_replication_tags.tags
}

module "shared_cloudendure_iam" {
  source = "../../modules/cloudendure_iam"
  providers = {
    aws        = aws.shared
    aws.shared = aws.shared
  }

  aws_account_id = local.aws_account_id
  aws_region     = local.aws_region
  cloudendure_iam_user_name = local.cloudendure_iam_user_name
  tags           = module.shared_cloudendure_replication_tags.tags
}
