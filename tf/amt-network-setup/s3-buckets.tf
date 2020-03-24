resource "aws_s3_bucket" "snapshot_bucket" {
  provider      = aws.shared
  bucket_prefix = "amt-shared-vmware-snapshot-"
  acl           = "private"
  tags          = module.shared_tags.tags
}
