locals {
  s3publicacct = var.accounts["s3public"]
}

provider "aws" {
  alias   = "s3public"
  version = "~> 2.8"

  assume_role {
    role_arn     = "arn:aws:iam::${local.s3publicacct.account_number}:role/${local.s3publicacct.root_role}"
    session_name = "lzdeploy-${local.s3publicacct.environment_affix}"
  }
}

module "s3public_tags" {
  providers = {
    aws = aws.s3public
  }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.3"

  business_unit        = var.cloud_governance_business_unit
  environment          = local.s3publicacct.environment_affix
  cost_center          = var.cloud_governance_cost_center
  application_name     = var.cloud_governance_application_name
  application_owner    = var.cloud_governance_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

module "s3public_baseline" {
  providers = {
    aws          = aws.s3public
    aws.logarch  = aws.logarch
    aws.security = aws.security
  }

  source  = "tfe.amtrustgroup.com/AmTrust/security-baseline/aws"
  version = ">= 0.5.0"

  environment_affix      = local.s3publicacct.environment_affix
  log_archive_s3_bucket  = aws_s3_bucket.log_archive.bucket
  account_email          = local.s3publicacct.email
  guardduty_master_id    = module.security_baseline.guardduty_id
  block_public_s3_access = false

  tags = module.s3public_tags.tags
}

resource "aws_s3_bucket" "public_share" {
  provider = aws.s3public

  bucket_prefix = "amt-share-"
  acl           = "authenticated-read"

  tags = module.s3public_tags.tags
}

resource "aws_s3_bucket_policy" "public_share" {
  provider = aws.s3public

  bucket = aws_s3_bucket.public_share.bucket
  policy = templatefile("${path.module}/policies/s3-public-share-policy.json", { bucket_arn = aws_s3_bucket.public_share.bucket })
}
