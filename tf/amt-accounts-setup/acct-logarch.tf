locals {
  logarchacct = var.accounts["logarch"]
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

  source = "tfe.amtrustgroup.com/AmTrust/tags/aws"

  business_unit        = var.cloud_governance_business_unit
  environment          = local.logarchacct.environment_affix
  cost_center          = var.cloud_governance_cost_center
  application_name     = var.cloud_governance_application_name
  application_owner    = var.cloud_governance_email
  infrastructure_owner = var.cloud_governance_email
}

resource "aws_s3_bucket" "log_archive" {
  provider = aws.logarch

  bucket_prefix = "amt-log-archive-"
  acl           = "private"

  lifecycle_rule {
    id      = "log"
    enabled = true
    prefix  = "log/"

    tags = {
      "rule"      = "log"
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

  lifecycle_rule {
    id      = "config"
    enabled = true
    prefix  = "config/"

    tags = {
      "rule"      = "config"
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

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(module.log_arch_tags.tags, { asset-role = "LogArchive" })
}

resource "aws_s3_bucket_policy" "log_archive" {
  provider = aws.logarch

  bucket = aws_s3_bucket.log_archive.bucket
  policy = templatefile("${path.module}/policies/s3-log-archive-bucket.json", { bucket_arn = aws_s3_bucket.log_archive.arn })
}

resource "aws_s3_bucket_public_access_block" "log_archive" {
  provider = aws.logarch

  bucket                  = aws_s3_bucket.log_archive.bucket
  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

module "log_arch_baseline" {
  providers = {
    aws         = aws.logarch
    aws.logarch = aws.logarch
  }

  source  = "tfe.amtrustgroup.com/AmTrust/security-baseline/aws"
  version = "~> 0.2.2"

  environment_short_name = local.logarchacct.environment_affix
  log_archive_s3_bucket  = aws_s3_bucket.log_archive.bucket

  tags = module.log_arch_tags.tags
}

module "guard_duty_logarch" {
  providers = {
    aws          = aws.logarch
    aws.security = aws.security
  }
  source = "./modules/guard_duty"

  master_guard_duty_id         = aws_guardduty_detector.security.id
  master_guard_duty_account_id = aws_guardduty_detector.security.account_id
  account_email                = local.logarchacct.email
}
