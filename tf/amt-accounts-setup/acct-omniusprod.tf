locals {
  omniusprodacct = var.accounts["omniusprod"]
}

provider "aws" {
  alias   = "omniusprod"
  version = "~> 2.8"

  assume_role {
    role_arn     = "arn:aws:iam::${local.omniusprodacct.account_number}:role/${local.omniusprodacct.root_role}"
    session_name = "lzdeploy-${local.omniusprodacct.environment_affix}"
  }
} # omniusprod

module "omnius_prod_tags" {
  providers = {
    aws = aws.omniusprod
  }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.3"

  business_unit        = var.cloud_governance_business_unit
  environment          = local.omniusprodacct.environment_affix
  cost_center          = var.cloud_governance_cost_center
  application_name     = var.cloud_governance_application_name
  application_owner    = var.cloud_governance_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

module "omnius_prod_baseline" {
  providers = {
    aws          = aws.omniusprod
    aws.logarch  = aws.logarch
    aws.security = aws.security
  }

  source  = "tfe.amtrustgroup.com/AmTrust/security-baseline/aws"
  version = ">= 0.4.0"

  environment_affix     = local.omniusprodacct.environment_affix
  log_archive_s3_bucket = aws_s3_bucket.log_archive.bucket
  account_email         = local.omniusprodacct.email
  guardduty_master_id   = module.security_baseline.guardduty_id

  tags = module.omnius_prod_tags.tags
}

resource "aws_budgets_budget" "budget_master_to_shared" {
  name              = "amt-master-omniusprod-budget"
  budget_type       = "COST"
  limit_amount      = "10000.0"
  limit_unit        = "USD"
  time_period_start = "2020-01-01_00:00"
  time_unit         = "MONTHLY"

  cost_filters = {
    LinkedAccount = local.omniusnonprodacct.account_number
  }

  cost_types {
    include_credit = false
    include_refund = false
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 110
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = ["michael.meadows@insight.com", "joseph.valdez@amtrustgroup.com"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = ["michael.meadows@insight.com", "joseph.valdez@amtrustgroup.com"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = ["michael.meadows@insight.com", "joseph.valdez@amtrustgroup.com"]
  }
}
