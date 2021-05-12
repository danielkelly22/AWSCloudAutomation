locals {
  sharedsvcacct = var.accounts["sharedsvc"]
}

provider "aws" {
  alias   = "sharedsvc"
  version = "~> 3.38.0"

  assume_role {
    role_arn     = "arn:aws:iam::${local.sharedsvcacct.account_number}:role/${local.sharedsvcacct.root_role}"
    session_name = "lzdeploy-${local.sharedsvcacct.environment_affix}"
  }
} # sharedsvc

module "shared_svc_tags" {
  providers = {
    aws = aws.sharedsvc
  }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.3"

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
    aws          = aws.sharedsvc
    aws.logarch  = aws.logarch
    aws.security = aws.security
  }

  source  = "tfe.amtrustgroup.com/AmTrust/security-baseline/aws"
  version = ">= 0.5.0"

  environment_affix      = local.sharedsvcacct.environment_affix
  log_archive_s3_bucket  = aws_s3_bucket.log_archive.bucket
  account_email          = local.sharedsvcacct.email
  guardduty_master_id    = module.security_baseline.guardduty_id
  block_public_s3_access = false

  tags = module.shared_svc_tags.tags
}
