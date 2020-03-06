locals {
  productionacct = var.accounts["production"]
}

provider "aws" {
  alias   = "production"
  version = "~> 2.8"

  assume_role {
    role_arn     = "arn:aws:iam::${local.productionacct.account_number}:role/${local.productionacct.root_role}"
    session_name = "lzdeploy-${local.productionacct.environment_affix}"
  }
} # production

module "production_tags" {
  providers = {
    aws = aws.production
  }

  source = "tfe.amtrustgroup.com/AmTrust/tags/aws"

  business_unit        = var.cloud_governance_business_unit
  environment          = local.productionacct.environment_affix
  cost_center          = var.cloud_governance_cost_center
  application_name     = var.cloud_governance_application_name
  application_owner    = var.cloud_governance_email
  infrastructure_owner = var.cloud_governance_email
}

module "production_baseline" {
  providers = {
    aws         = aws.production
    aws.logarch = aws.logarch
  }

  source  = "tfe.amtrustgroup.com/AmTrust/security-baseline/aws"
  version = "~> 0.2.2"

  environment_short_name = local.productionacct.environment_affix
  log_archive_s3_bucket  = aws_s3_bucket.log_archive.bucket

  tags = module.production_tags.tags
}

module "guard_duty_production" {
  providers = {
    aws          = aws.production
    aws.security = aws.security
  }
  source = "./modules/guard_duty"

  master_guard_duty_id         = aws_guardduty_detector.security.id
  master_guard_duty_account_id = aws_guardduty_detector.security.account_id
  account_email                = local.productionacct.email
}
