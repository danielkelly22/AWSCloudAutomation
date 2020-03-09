locals {
  securityacct = var.accounts["security"]
}

provider "aws" {
  alias   = "security"
  version = "~> 2.8"

  assume_role {
    role_arn     = "arn:aws:iam::${local.securityacct.account_number}:role/${local.securityacct.root_role}"
    session_name = "lzdeploy-${local.securityacct.environment_affix}"
  }
} # security

module "security_tags" {
  providers = {
    aws = aws.security
  }

  source = "tfe.amtrustgroup.com/AmTrust/tags/aws"

  business_unit        = var.cloud_governance_business_unit
  environment          = local.securityacct.environment_affix
  cost_center          = var.cloud_governance_cost_center
  application_name     = var.cloud_governance_application_name
  application_owner    = var.cloud_governance_email
  infrastructure_owner = var.cloud_governance_email
}

module "security_baseline" {
  providers = {
    aws         = aws.security
    aws.logarch = aws.logarch
  }

  source  = "tfe.amtrustgroup.com/AmTrust/security-baseline/aws"
  version = ">= 0.3.0"

  environment_short_name = local.securityacct.environment_affix
  log_archive_s3_bucket  = aws_s3_bucket.log_archive.bucket

  tags = module.security_tags.tags
}

resource "aws_guardduty_detector" "security" {
  provider = aws.security
}
