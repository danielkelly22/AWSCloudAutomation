resource "aws_kms_key" "snapshot_bucket" {
  provider                = aws.shared
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  tags = merge(module.shared_tags.tags, {
    Name = "amt-shared-vmware-snapshot-key"
  })
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
resource "aws_s3_bucket_policy" "snapshot_bucket" {
  provider = aws.shared
  bucket   = aws_s3_bucket.snapshot_bucket.bucket
  policy   = templatefile("${path.module}/policies/vmware-snapshot-policy.json", { bucket_arn = aws_s3_bucket.snapshot_bucket.arn })
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
  bucket   = aws_s3_bucket.snapshot_bucket.bucket
  name     = "amt-transit-vpc-access-point"
  vpc_configuration {
    vpc_id = "vpc-04de814c0d3cfdd96"
  }
  # policy = templatefile("${path.module}/policies/access-point-policy.json", { bucket_arn = aws_s3_bucket.snapshot_bucket.arn })
  public_access_block_configuration {
    block_public_acls       = true
    block_public_policy     = false
    ignore_public_acls      = true
    restrict_public_buckets = false
  }
}
output "kms_id" {
  value = aws_kms_key.snapshot_bucket.id
}
output "bucket" {
  value = aws_s3_bucket.snapshot_bucket.bucket
}
output "access_point_arn" {
  value = aws_s3_access_point.snapshot_bucket.arn
}
