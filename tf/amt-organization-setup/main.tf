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
  aws_service_access_principals = var.organization_service_access_principals
  enabled_policy_types          = var.organization_enabled_policy_types
  feature_set                   = var.organization_feature_set
}

locals {
  organization_id = aws_organizations_organization.org.roots.0.id
}
