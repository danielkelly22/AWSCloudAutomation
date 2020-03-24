resource "aws_s3_bucket" "snapshot_bucket" {
  provider      = aws.shared
  bucket_prefix = "amt-shared-vmware-snapshot-"
  acl           = "private"
  tags          = module.shared_tags.tags
}

resource "aws_s3_bucket_public_access_block" "snapshot_bucket" {
  provider                = aws.shared
  bucket                  = aws_s3_bucket.snapshot_bucket.bucket
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "snapshot_bucket" {
  provider = aws.shared
  bucket   = aws_s3_bucket.snapshot_bucket.bucket
  policy   = templatefile("${path.module}/policies/snapshot-bucket.json", { bucket_arn = aws_s3_bucket.snapshot_bucket.arn })
}
