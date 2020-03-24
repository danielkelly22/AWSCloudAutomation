locals {
  logarchacct       = var.accounts["logarch"]
  lifecycle_folders = ["log", "config"]
}

provider "aws" {
  alias   = "logarch"
  version = "~> 2.8"

  assume_role {
    role_arn     = "arn:aws:iam::${local.logarchacct.account_number}:role/${local.logarchacct.root_role}"
    session_name = "lzdeploy-${local.logarchacct.environment_affix}"
  }
} # logarch

module "log_arch_tags" {
  providers = {
    aws = aws.logarch
  }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.3"

  business_unit        = var.cloud_governance_business_unit
  environment          = local.logarchacct.environment_affix
  cost_center          = var.cloud_governance_cost_center
  application_name     = var.cloud_governance_application_name
  application_owner    = var.cloud_governance_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

resource "aws_s3_bucket" "log_archive" {
  provider = aws.logarch

  bucket_prefix = "amt-log-archive-"
  acl           = "private"

  dynamic "lifecycle_rule" {
    iterator = current
    for_each = local.lifecycle_folders

    content {
      id      = current.value
      enabled = true
      prefix  = "${current.value}/"

      tags = {
        "rule"      = current.value
        "autoclean" = "true"
      }

      transition {
        days          = 45
        storage_class = "STANDARD_IA"
      }

      transition {
        days          = 90
        storage_class = "GLACIER"
      }

      expiration {
        days = 2738 # 365 * 7.5 (about 7 1/2 years)
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(module.log_arch_tags.tags, {
    asset-role  = "LogArchive"
    description = "Write-only S3 bucket that is used to archive any log data."
  })
}

resource "aws_s3_bucket_policy" "log_archive" {
  provider = aws.logarch

  bucket = aws_s3_bucket.log_archive.bucket
  policy = templatefile("${path.module}/policies/s3-log-archive-bucket.json", { bucket_arn = aws_s3_bucket.log_archive.arn })
}

module "log_arch_baseline" {
  providers = {
    aws          = aws.logarch
    aws.logarch  = aws.logarch
    aws.security = aws.security
  }

  source  = "tfe.amtrustgroup.com/AmTrust/security-baseline/aws"
  version = ">= 0.5.0"

  environment_affix      = local.logarchacct.environment_affix
  log_archive_s3_bucket  = aws_s3_bucket.log_archive.bucket
  account_email          = local.logarchacct.email
  guardduty_master_id    = module.security_baseline.guardduty_id
  block_public_s3_access = false

  tags = module.log_arch_tags.tags
}
