resource "aws_kms_key" "snapshot_bucket" {
  provider                = aws.shared
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  tags                    = module.shared_tags.tags
}

resource "aws_kms_alias" "snapshot_bucket" {
  provider      = aws.shared
  target_key_id = aws_kms_key.snapshot_bucket.id
  name          = "alias/amt-shared-vmware-snapshot-key"
}

resource "aws_s3_bucket" "snapshot_bucket" {
  provider      = aws.shared
  bucket_prefix = "amt-shared-vmware-snapshot-"
  acl           = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.snapshot_bucket.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  tags = module.shared_tags.tags
}

resource "aws_s3_bucket_public_access_block" "snapshot_bucket" {
  provider                = aws.shared
  bucket                  = aws_s3_bucket.snapshot_bucket.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_access_point" "snapshot_bucket" {
  provider = aws.shared

  bucket = aws_s3_bucket.snapshot_bucket.bucket
  name   = "amt-snapshot-bucket-access-point"

  policy = templatefile("${path.module}/policies/vmware-snapshot-access-point.json", { bucket_arn = aws_s3_bucket.snapshot_bucket.arn })

  public_access_block_configuration {
    block_public_acls       = true
    block_public_policy     = false
    ignore_public_acls      = true
    restrict_public_buckets = false
  }
}
