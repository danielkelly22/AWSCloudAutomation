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

  source = "tfe.amtrustgroup.com/AmTrust/tags/aws"

  business_unit        = var.cloud_governance_business_unit
  environment          = local.devacct.environment_affix
  cost_center          = var.cloud_governance_cost_center
  application_name     = var.cloud_governance_application_name
  application_owner    = var.cloud_governance_email
  infrastructure_owner = var.cloud_governance_email
}

module "development_baseline" {
  providers = {
    aws         = aws.development
    aws.logarch = aws.logarch
  }

  source  = "tfe.amtrustgroup.com/AmTrust/security-baseline/aws"
  version = ">= 0.3.0"

  environment_short_name = local.devacct.environment_affix
  log_archive_s3_bucket  = aws_s3_bucket.log_archive.bucket

  tags = module.development_tags.tags
}

module "guard_duty_development" {
  providers = {
    aws          = aws.development
    aws.security = aws.security
  }
  source = "./modules/guard_duty"

  master_guard_duty_id         = aws_guardduty_detector.security.id
  master_guard_duty_account_id = aws_guardduty_detector.security.account_id
  account_email                = local.devacct.email
}
