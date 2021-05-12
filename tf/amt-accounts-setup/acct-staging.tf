locals {
  stagingacct = var.accounts["staging"]
}

provider "aws" {
  alias   = "staging"
  version = "~> 3.38.0"

  assume_role {
    role_arn     = "arn:aws:iam::${local.stagingacct.account_number}:role/${local.stagingacct.root_role}"
    session_name = "lzdeploy-${local.stagingacct.environment_affix}"
  }
} # staging

module "staging_tags" {
  providers = {
    aws = aws.staging
  }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.3"

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
    aws          = aws.staging
    aws.logarch  = aws.logarch
    aws.security = aws.security
  }

  source  = "tfe.amtrustgroup.com/AmTrust/security-baseline/aws"
  version = ">= 0.5.0"

  environment_affix     = local.stagingacct.environment_affix
  log_archive_s3_bucket = aws_s3_bucket.log_archive.bucket
  account_email         = local.stagingacct.email
  guardduty_master_id   = module.security_baseline.guardduty_id

  tags = module.staging_tags.tags
}
