locals {
  testacct = var.accounts["test"]
}

provider "aws" {
  alias   = "test"
  version = "~> 2.8"

  assume_role {
    role_arn     = "arn:aws:iam::${local.testacct.account_number}:role/${local.testacct.root_role}"
    session_name = "lzdeploy-${local.testacct.environment_affix}"
  }
} # test

module "test_tags" {
  providers = {
    aws = aws.test
  }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.3"

  business_unit        = var.cloud_governance_business_unit
  environment          = local.testacct.environment_affix
  cost_center          = var.cloud_governance_cost_center
  application_name     = var.cloud_governance_application_name
  application_owner    = var.cloud_governance_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

module "test_baseline" {
  providers = {
    aws          = aws.test
    aws.logarch  = aws.logarch
    aws.security = aws.security
  }

  source  = "tfe.amtrustgroup.com/AmTrust/security-baseline/aws"
  version = ">= 0.5.0"

  environment_affix     = local.testacct.environment_affix
  log_archive_s3_bucket = aws_s3_bucket.log_archive.bucket
  account_email         = local.testacct.email
  guardduty_master_id   = module.security_baseline.guardduty_id

  tags = module.test_tags.tags
}
