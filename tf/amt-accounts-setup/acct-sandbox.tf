locals {
  sandboxacct = var.accounts["sandbox"]
}

provider "aws" {
  alias   = "sandbox"
  version = "~> 2.8"

  assume_role {
    role_arn     = "arn:aws:iam::${local.sandboxacct.account_number}:role/${local.sandboxacct.root_role}"
    session_name = "lzdeploy-${local.sandboxacct.environment_affix}"
  }
} # sandbox

module "sandbox_tags" {
  providers = {
    aws = aws.sandbox
  }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.3"

  business_unit        = var.cloud_governance_business_unit
  environment          = local.sandboxacct.environment_affix
  cost_center          = var.cloud_governance_cost_center
  application_name     = var.cloud_governance_application_name
  application_owner    = var.cloud_governance_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

module "sandbox_baseline" {
  providers = {
    aws          = aws.sandbox
    aws.logarch  = aws.logarch
    aws.security = aws.security
  }

  source  = "tfe.amtrustgroup.com/AmTrust/security-baseline/aws"
  version = ">= 0.4.0"

  environment_affix     = local.sandboxacct.environment_affix
  log_archive_s3_bucket = aws_s3_bucket.log_archive.bucket
  account_email         = local.sandboxacct.email
  guardduty_master_id   = module.security_baseline.guardduty_id

  tags = module.sandbox_tags.tags
}
