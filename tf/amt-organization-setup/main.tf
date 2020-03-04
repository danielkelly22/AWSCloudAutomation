terraform {
  backend "remote" {
    hostname     = "tfe.amtrustgroup.com"
    organization = "AmTrust"

    workspaces {
      name = "amt-organization-setup"
    }
  }
}

provider "aws" {
  version = "~> 2.8"
}

### Organization
resource "aws_organizations_organization" "org" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "ram.amazonaws.com",
    "sso.amazonaws.com",
    "tagpolicies.tag.amazonaws.com"
  ]
  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY"
  ]
  feature_set = "ALL"
}

locals {
  organization_id = aws_organizations_organization.org.roots.0.id
}
