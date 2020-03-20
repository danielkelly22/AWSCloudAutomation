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

  source = "tfe.amtrustgroup.com/AmTrust/tags/aws"

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
    aws         = aws.omniusnonprod
    aws.logarch = aws.logarch
  }

  source  = "tfe.amtrustgroup.com/AmTrust/security-baseline/aws"
  version = ">= 0.3.0"

  environment_short_name = local.omniusnonprodacct.environment_affix
  log_archive_s3_bucket  = aws_s3_bucket.log_archive.bucket

  tags = module.omnius_nonprod_tags.tags
}

module "guard_duty_omniusnonprod" {
  providers = {
    aws          = aws.omniusnonprod
    aws.security = aws.security
  }
  source = "./modules/guard_duty"

  master_guard_duty_id         = aws_guardduty_detector.security.id
  master_guard_duty_account_id = aws_guardduty_detector.security.account_id
  account_email                = local.omniusnonprodacct.email
}

resource "aws_budgets_budget" "budget_master_to_shared" {
  name              = "amt-master-omniusprod-budget"
  budget_type       = "COST"
  limit_amount      = "10000"
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
