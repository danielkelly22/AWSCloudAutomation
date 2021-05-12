locals {
  smartcommprod_account = var.accounts["amt-aws-smartcomm-prod"]
}

provider "aws" {
  alias   = "smartcommprod"
  version = "~> 3.38.0"

  assume_role {
    role_arn     = "arn:aws:iam::${local.smartcommprod_account.account_number}:role/${local.smartcommprod_account.root_role}"
    session_name = "lzdeploy-${local.smartcommprod_account.environment_affix}"
  }
}

module "smartcommprod_tags" {
  providers = {
    aws = aws.smartcommprod
  }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.3"

  business_unit        = var.cloud_governance_business_unit
  environment          = local.smartcommprod_account.environment_affix
  cost_center          = var.cloud_governance_cost_center
  application_name     = var.cloud_governance_application_name
  application_owner    = var.cloud_governance_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

module "smartcommprod_nonprod_baseline" {
  providers = {
    aws          = aws.smartcommprod
    aws.logarch  = aws.logarch
    aws.security = aws.security
  }

  source  = "tfe.amtrustgroup.com/AmTrust/security-baseline/aws"
  version = ">= 0.5.0"

  environment_affix      = local.smartcommprod_account.environment_affix
  log_archive_s3_bucket  = aws_s3_bucket.log_archive.bucket
  account_email          = local.smartcommprod_account.email
  guardduty_master_id    = module.security_baseline.guardduty_id
  block_public_s3_access = true

  tags = module.smartcommprod_tags.tags
}
