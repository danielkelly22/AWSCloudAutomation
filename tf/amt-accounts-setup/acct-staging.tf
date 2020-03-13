locals {
  stagingacct = var.accounts["staging"]
}

provider "aws" {
  alias   = "staging"
  version = "~> 2.8"

  assume_role {
    role_arn     = "arn:aws:iam::${local.stagingacct.account_number}:role/${local.stagingacct.root_role}"
    session_name = "lzdeploy-${local.stagingacct.environment_affix}"
  }
} # staging

module "staging_tags" {
  providers = {
    aws = aws.staging
  }

  source = "tfe.amtrustgroup.com/AmTrust/tags/aws"

  business_unit        = var.cloud_governance_business_unit
  environment          = local.stagingacct.environment_affix
  cost_center          = var.cloud_governance_cost_center
  application_name     = var.cloud_governance_application_name
  application_owner    = var.cloud_governance_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

module "staging_baseline" {
  providers = {
    aws         = aws.staging
    aws.logarch = aws.logarch
  }

  source  = "tfe.amtrustgroup.com/AmTrust/security-baseline/aws"
  version = ">= 0.3.0"

  environment_short_name = local.stagingacct.environment_affix
  log_archive_s3_bucket  = aws_s3_bucket.log_archive.bucket

  tags = module.staging_tags.tags
}

module "guard_duty_staging" {
  providers = {
    aws          = aws.staging
    aws.security = aws.security
  }
  source = "./modules/guard_duty"

  master_guard_duty_id         = aws_guardduty_detector.security.id
  master_guard_duty_account_id = aws_guardduty_detector.security.account_id
  account_email                = local.stagingacct.email
}
