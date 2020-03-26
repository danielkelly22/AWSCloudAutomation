resource "aws_organizations_policy" "limit_regions" {
  name        = "AMTLimitRegions"
  description = "Limits AWS regions to approved AmTrust regions."

  content = file("${path.module}/policies/scp-limit-regions.json")
}

resource "aws_organizations_policy" "disable_egress" {
  name        = "AMTPreventInternetAccess"
  description = "Disallows users creating their own data egress."

  content = file("${path.module}/policies/scp-disable-egress.json")
}

resource "aws_organizations_policy" "lock_down_cloudtrail" {
  name        = "AMTLockDownCloudTrail"
  description = "Prevents users from stopping CloudTrail logging."

  content = file("${path.module}/policies/scp-lock-down-cloud-trail.json")
}

resource "aws_organizations_policy" "deny_all" {
  name        = "AMTDenyAll"
  description = "Denies all actions."

  content = file("${path.module}/policies/scp-deny-all.json")
}

resource "aws_organizations_policy" "require_s3_encryption" {
  name        = "AMTRequireS3Encryption"
  description = "Requires that anything stored on S3 is encrypted."

  content = templatefile("${path.module}/policies/scp-require-s3-encryption-except-s3public.json", { public_s3_account = aws_organizations_account.accounts["s3public"].id })
  # content = templatefile("${path.module}/policies/scp-require-s3-encryption.json", { public_s3_account = aws_organizations_account.accounts["s3public"].id })
}

### Policy Attachments
resource "aws_organizations_policy_attachment" "root_limit_regions" {
  policy_id = aws_organizations_policy.limit_regions.id
  target_id = local.organization_id
}

resource "aws_organizations_policy_attachment" "root_lock_down_cloudtrail" {
  policy_id = aws_organizations_policy.lock_down_cloudtrail.id
  target_id = local.organization_id
}

resource "aws_organizations_policy_attachment" "root_require_s3_encryption" {
  policy_id = aws_organizations_policy.require_s3_encryption.id
  target_id = local.organizational_units.production # Set back to the organization after testing
  # target_id = local.organization_id
}

resource "aws_organizations_policy_attachment" "nonprod_disable_egress" {
  policy_id = aws_organizations_policy.disable_egress.id
  target_id = aws_organizations_organizational_unit.nonprod.id
}

resource "aws_organizations_policy_attachment" "production_disable_egress" {
  policy_id = aws_organizations_policy.disable_egress.id
  target_id = aws_organizations_organizational_unit.production.id
}

resource "aws_organizations_policy_attachment" "deny_all" {
  policy_id = aws_organizations_policy.lock_down_cloudtrail.id
  target_id = aws_organizations_organizational_unit.quarantine.id
}
