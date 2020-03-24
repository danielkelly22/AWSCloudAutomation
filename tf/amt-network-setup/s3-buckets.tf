resource "aws_s3_bucket" "snapshot_bucket" {
  provider = aws.shared
  bucket   = "amt-vmware-snapshot-bucket"
  acl      = "private"
  tags     = module.shared_tags.tags
}
