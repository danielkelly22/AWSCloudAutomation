################################################
# main
################################################
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

################################################
# IAM
################################################
data "template_file" "instance_role_policy" {
  template = file("${path.module}/templates/tfe-instance-role-policy.json")

  vars = {
    tfe_app_bucket_arn       = aws_s3_bucket.tfe_app.arn
    tfe_bootstrap_bucket_arn = data.aws_s3_bucket.tfe_bootstrap.arn
    aws_kms_arn              = var.kms_key_arn
    aws_secret_arn           = var.aws_secret_arn
  }
}

################################################
# compute
################################################
data "template_file" "tfe_user_data" {
  template = "${file("${path.module}/templates/tfe_${var.tfe_os_type}_user_data.sh")}"

  vars = {
    tfe_hostname          = var.tfe_hostname
    tfe_release_sequence  = var.tfe_release_sequence
    tfe_bootstrap_bucket  = var.tfe_bootstrap_bucket
    tfe_app_bucket_name   = aws_s3_bucket.tfe_app.id
    tfe_app_bucket_region = data.aws_region.current.name
    kms_key_arn           = var.kms_key_arn
    secrets_mgmt          = var.secrets_mgmt
    aws_secret_arn        = var.aws_secret_arn
    pg_netloc             = aws_db_instance.tfe_rds.endpoint
    pg_dbname             = aws_db_instance.tfe_rds.name
    pg_user               = aws_db_instance.tfe_rds.username
    pg_password           = aws_db_instance.tfe_rds.password
  }
}

data "template_cloudinit_config" "tfe_cloud_config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "tfe_cloud_init.txt"
    content_type = "text/x-shellscript"
    content      = data.template_file.tfe_user_data.rendered
  }
}

################################################
# S3
################################################
data "aws_s3_bucket" "tfe_bootstrap" {
  bucket = var.tfe_bootstrap_bucket
}

data "template_file" "tfe_app_bucket_policy" {
  template = file("${path.module}/templates/tfe-app-bucket-policy.json")

  vars = {
    tfe_app_bucket_arn     = aws_s3_bucket.tfe_app.arn
    current_iam_caller_id  = data.aws_caller_identity.current.user_id
    tfe_iam_role_unique_id = aws_iam_role.tfe_instance_role.arn
  }
}


