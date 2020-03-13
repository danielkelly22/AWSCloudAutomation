locals {
  sharedsvcacct = var.accounts["sharedsvc"]
}

provider "aws" {
  alias   = "sharedsvc"
  version = "~> 2.8"

  assume_role {
    role_arn     = "arn:aws:iam::${local.sharedsvcacct.account_number}:role/${local.sharedsvcacct.root_role}"
    session_name = "lzdeploy-${local.sharedsvcacct.environment_affix}"
  }
} # sharedsvc

module "shared_svc_tags" {
  providers = {
    aws = aws.sharedsvc
  }

  source = "tfe.amtrustgroup.com/AmTrust/tags/aws"

  business_unit        = var.cloud_governance_business_unit
  environment          = local.sharedsvcacct.environment_affix
  cost_center          = var.cloud_governance_cost_center
  application_name     = var.cloud_governance_application_name
  application_owner    = var.cloud_governance_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

module "shared_svc_baseline" {
  providers = {
    aws         = aws.sharedsvc
    aws.logarch = aws.logarch
  }

  source  = "tfe.amtrustgroup.com/AmTrust/security-baseline/aws"
  version = ">= 0.3.0"

  environment_short_name = local.sharedsvcacct.environment_affix
  log_archive_s3_bucket  = aws_s3_bucket.log_archive.bucket

  tags = module.shared_svc_tags.tags
}

module "guard_duty_sharedsvc" {
  providers = {
    aws          = aws.sharedsvc
    aws.security = aws.security
  }
  source = "./modules/guard_duty"

  master_guard_duty_id         = aws_guardduty_detector.security.id
  master_guard_duty_account_id = aws_guardduty_detector.security.account_id
  account_email                = local.sharedsvcacct.email
}
