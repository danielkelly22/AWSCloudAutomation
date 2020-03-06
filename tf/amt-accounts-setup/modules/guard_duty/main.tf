provider "aws" {
  version = "~> 2.8"
}

provider "aws" {
  version = "~> 2.8"
  alias   = "security"
}

resource "aws_guardduty_detector" "guardduty" {}

resource "aws_guardduty_member" "guardduty" {
  provider = aws.security

  account_id  = aws_guardduty_detector.guardduty.account_id
  detector_id = var.master_guard_duty_id
  email       = var.account_email
  invite      = true
}

resource "aws_guardduty_invite_accepter" "guardduty" {
  detector_id       = aws_guardduty_detector.guardduty.id
  master_account_id = var.master_guard_duty_account_id

  # This is required because the invitation has to be sent before it can be accepted
  depends_on = [aws_guardduty_member.guardduty]
}
