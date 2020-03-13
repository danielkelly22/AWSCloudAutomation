locals {
  omniusprodacct = var.accounts["omniusprod"]
}

provider "aws" {
  alias   = "omniusprod"
  version = "~> 2.8"

  assume_role {
    role_arn     = "arn:aws:iam::${local.omniusprodacct.account_number}:role/${local.omniusprodacct.root_role}"
    session_name = "lzdeploy-${local.omniusprodacct.environment_affix}"
  }
} # omniusprod

module "omnius_prod_tags" {
  providers = {
    aws = aws.omniusprod
  }

  source = "tfe.amtrustgroup.com/AmTrust/tags/aws"

  business_unit        = var.cloud_governance_business_unit
  environment          = local.omniusprodacct.environment_affix
  cost_center          = var.cloud_governance_cost_center
  application_name     = var.cloud_governance_application_name
  application_owner    = var.cloud_governance_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

module "omnius_prod_baseline" {
  providers = {
    aws         = aws.omniusprod
    aws.logarch = aws.logarch
  }

  source  = "tfe.amtrustgroup.com/AmTrust/security-baseline/aws"
  version = ">= 0.3.0"

  environment_short_name = local.omniusprodacct.environment_affix
  log_archive_s3_bucket  = aws_s3_bucket.log_archive.bucket

  tags = module.omnius_prod_tags.tags
}

module "guard_duty_omniusprod" {
  providers = {
    aws          = aws.omniusprod
    aws.security = aws.security
  }
  source = "./modules/guard_duty"

  master_guard_duty_id         = aws_guardduty_detector.security.id
  master_guard_duty_account_id = aws_guardduty_detector.security.account_id
  account_email                = local.omniusprodacct.email
}
