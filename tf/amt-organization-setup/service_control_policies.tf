resource "aws_organizations_policy" "limit_regions" {
  name        = "AMTLimitRegions"
  description = "Limits AWS regions to approved AmTrust regions."

  content = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DenyAllOutsideEU",
            "Effect": "Deny",
            "NotAction": [
                "iam:*",
                "organizations:*",
                "route53:*",
                "budgets:*",
                "waf:*",
                "cloudfront:*",
                "globalaccelerator:*",
                "importexport:*",
                "support:*"
            ],
            "Resource": "*",
            "Condition": {
                "StringNotEquals": {
                    "aws:RequestedRegion": [
                        "us-east-1",
                        "us-east-2"
                    ]
                }
            }
        }
    ]
}
EOF
}

resource "aws_organizations_policy" "disable_egress" {
  name        = "AMTPreventInternetAccess"
  description = "Disallows users creating their own data egress."

  content = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Action": [
                "ec2:AttachInternetGateway",
                "ec2:CreateInternetGateway",
                "ec2:CreateEgressOnlyInternetGateway",
                "ec2:CreateVpcPeeringConnection",
                "ec2:AcceptVpcPeeringConnection",
                "globalaccelerator:Create*",
                "globalaccelerator:Update*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_organizations_policy" "lock_down_cloudtrail" {
  name        = "AMTLockDownCloudTrail"
  description = "Prevents users from stopping CloudTrail logging."

  content = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Action": "cloudtrail:StopLogging",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_organizations_policy" "deny_all" {
  name        = "AMTDenyAll"
  description = "Denies all actions."

  content = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Action": "cloudtrail:StopLogging",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_organizations_policy" "require_s3_encryption" {
  name        = "AMTRequireS3Encryption"
  description = "Requires that anything stored on S3 is encrypted."

  content = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DenyIncorrectEncryptionHeader",
            "Effect": "Deny",
            "Action": "s3:PutObject",
            "Resource": "*",
            "Condition": {
                "ForAllValues:StringNotEquals": {
                    "s3:x-amz-server-side-encryption": ["AES256","aws:kms"]
                }
            }
        },
        {
            "Sid": "DenyUnEncryptedObjectUploads",
            "Effect": "Deny",
            "Action": "s3:PutObject",
            "Resource": "*",
            "Condition": {
                "Null": {
                    "s3:x-amz-server-side-encryption": true
                }
            }
        }
    ]
}
EOF
}

### Policy Attachments
resource "aws_organizations_policy_attachment" "root_limit_regions" {
  policy_id = aws_organizations_policy.limit_regions.id
  target_id = aws_organizations_organization.org.roots.0.id
}

resource "aws_organizations_policy_attachment" "root_lock_down_cloudtrail" {
  policy_id = aws_organizations_policy.lock_down_cloudtrail.id
  target_id = aws_organizations_organization.org.roots.0.id
}

resource "aws_organizations_policy_attachment" "root_require_s3_encryption" {
  policy_id = aws_organizations_policy.require_s3_encryption.id
  target_id = aws_organizations_organization.org.roots.0.id
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
