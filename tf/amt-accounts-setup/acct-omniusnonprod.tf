locals {
  omniusnonprodacct = var.accounts["omniusnonprod"]
}

provider "aws" {
  alias   = "omniusnonprod"
  version = "~> 2.8"

  assume_role {
    role_arn     = "arn:aws:iam::${local.omniusnonprodacct.account_number}:role/${local.omniusnonprodacct.root_role}"
    session_name = "lzdeploy-${local.omniusnonprodacct.environment_affix}"
  }
} # omniusprod

module "omnius_nonprod_tags" {
  providers = {
    aws = aws.omniusnonprod
  }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.3"

  business_unit        = var.cloud_governance_business_unit
  environment          = local.omniusnonprodacct.environment_affix
  cost_center          = var.cloud_governance_cost_center
  application_name     = var.cloud_governance_application_name
  application_owner    = var.cloud_governance_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

module "omnius_nonprod_baseline" {
  providers = {
    aws          = aws.omniusnonprod
    aws.logarch  = aws.logarch
    aws.security = aws.security
  }

  source  = "tfe.amtrustgroup.com/AmTrust/security-baseline/aws"
  version = ">= 0.4.0"

  environment_affix     = local.omniusnonprodacct.environment_affix
  log_archive_s3_bucket = aws_s3_bucket.log_archive.bucket
  account_email         = local.omniusnonprodacct.email
  guardduty_master_id   = module.security_baseline.guardduty_id

  tags = module.omnius_nonprod_tags.tags
}
