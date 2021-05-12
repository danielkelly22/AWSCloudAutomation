locals {
  smartcommdev_account = var.accounts["amt-aws-smartcomm-dev"]
}

provider "aws" {
  alias   = "smartcommdev"
  version = "~> 3.38.0"

  assume_role {
    role_arn     = "arn:aws:iam::${local.smartcommdev_account.account_number}:role/${local.smartcommdev_account.root_role}"
    session_name = "lzdeploy-${local.smartcommdev_account.environment_affix}"
  }
}

module "smartcommdev_tags" {
  providers = {
    aws = aws.smartcommdev
  }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.3"

  business_unit        = var.cloud_governance_business_unit
  environment          = local.smartcommdev_account.environment_affix
  cost_center          = var.cloud_governance_cost_center
  application_name     = var.cloud_governance_application_name
  application_owner    = var.cloud_governance_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

module "smartcommdev_nonprod_baseline" {
  providers = {
    aws          = aws.smartcommdev
    aws.logarch  = aws.logarch
    aws.security = aws.security
  }

  source  = "tfe.amtrustgroup.com/AmTrust/security-baseline/aws"
  version = ">= 0.5.0"

  environment_affix      = local.smartcommdev_account.environment_affix
  log_archive_s3_bucket  = aws_s3_bucket.log_archive.bucket
  account_email          = local.smartcommdev_account.email
  guardduty_master_id    = module.security_baseline.guardduty_id
  block_public_s3_access = true

  tags = module.smartcommdev_tags.tags
}
