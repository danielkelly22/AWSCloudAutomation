locals {
  productionacct = var.accounts["production"]
}

provider "aws" {
  alias   = "production"
  version = "~> 3.38.0"

  assume_role {
    role_arn     = "arn:aws:iam::${local.productionacct.account_number}:role/${local.productionacct.root_role}"
    session_name = "lzdeploy-${local.productionacct.environment_affix}"
  }
} # production

module "production_tags" {
  providers = {
    aws = aws.production
  }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.3"

  business_unit        = var.cloud_governance_business_unit
  environment          = local.productionacct.environment_affix
  cost_center          = var.cloud_governance_cost_center
  application_name     = var.cloud_governance_application_name
  application_owner    = var.cloud_governance_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

module "production_baseline" {
  providers = {
    aws          = aws.production
    aws.logarch  = aws.logarch
    aws.security = aws.security
  }

  source  = "tfe.amtrustgroup.com/AmTrust/security-baseline/aws"
  version = ">= 0.5.0"

  environment_affix     = local.productionacct.environment_affix
  log_archive_s3_bucket = aws_s3_bucket.log_archive.bucket
  account_email         = local.productionacct.email
  guardduty_master_id   = module.security_baseline.guardduty_id

  tags = module.production_tags.tags
}
