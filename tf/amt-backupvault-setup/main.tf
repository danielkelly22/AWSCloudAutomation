provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::207476187760:role/SharedSvcRoot"
  }
}


module "shared_tags" {
  source               = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  business_unit        = var.cloud_governance_business_unit
  environment          = "sharedsvc"
  cost_center          = var.cloud_governance_cost_center
  application_name     = var.cloud_governance_application_name
  application_owner    = var.cloud_governance_email
  infrastructure_owner = var.cloud_governance_email
}


resource "aws_kms_key" "sharedsvc_kms_key" {
  description = "KMS Key for AWS backup vault"
  tags = merge(module.shared_tags.tags, {
    Name = "amt-sharedsvc-kms-key"
  })
}
resource "aws_backup_vault" "sharedsvc_vault" {
  name        = "amt-sharedsvc-backup-vault"
  kms_key_arn = "${aws_kms_key.sharedsvc_kms_key.arn}"
}
resource "aws_backup_plan" "backup_sharedsvc" {
  name = "amt-backup-sharedsvc"
  rule {
    rule_name         = "backup_daily"
    target_vault_name = "${aws_backup_vault.sharedsvc_vault.name}"
    schedule          = "cron(0 6 * * ? *)"
    lifecycle {
      cold_storage_after = 90
      delete_after       = 365
    }
  }
}
data "aws_db_instance" "tfe_rds" {
  db_instance_identifier = "tfe-tfe-rds-207476187760"
}
data "aws_iam_role" "sharedsvc_backup" {
  name = "AWSBackupDefaultServiceRole"
}


resource "aws_backup_selection" "sharedsvc_selections" {
  iam_role_arn = data.aws_iam_role.sharedsvc_backup.arn
  name         = "sharedsvc_selections"
  plan_id      = aws_backup_plan.backup_sharedsvc.id

  resources = [
    data.aws_db_instance.tfe_rds.db_instance_arn
  ]
}

