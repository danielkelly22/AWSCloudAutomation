locals {
  devacct = var.accounts["development"]
}

provider "aws" {
  alias   = "development"
  version = "~> 2.8"

  assume_role {
    role_arn     = "arn:aws:iam::${local.devacct.account_number}:role/${local.devacct.root_role}"
    session_name = "lzdeploy-${local.devacct.environment_affix}"
  }
}

module "development_tags" {
  providers = {
    aws = aws.development
  }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.3"

  business_unit        = var.cloud_governance_business_unit
  environment          = local.devacct.environment_affix
  cost_center          = var.cloud_governance_cost_center
  application_name     = var.cloud_governance_application_name
  application_owner    = var.cloud_governance_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

module "development_baseline" {
  providers = {
    aws          = aws.development
    aws.logarch  = aws.logarch
    aws.security = aws.security
  }

  source  = "tfe.amtrustgroup.com/AmTrust/security-baseline/aws"
  version = ">= 0.5.0"

  environment_affix     = local.devacct.environment_affix
  log_archive_s3_bucket = aws_s3_bucket.log_archive.bucket
  account_email         = local.devacct.email
  guardduty_master_id   = module.security_baseline.guardduty_id

  tags = module.development_tags.tags
}
