resource "aws_organizations_organizational_unit" "nonprod" {
  name = "NonProduction"

  parent_id = local.organization_id
}

resource "aws_organizations_organizational_unit" "sandbox" {
  name = "Sandbox"

  parent_id = local.organization_id
}

resource "aws_organizations_organizational_unit" "production" {
  name = "Production"

  parent_id = local.organization_id
}

resource "aws_organizations_organizational_unit" "vendormanaged" {
  name = "VendorManaged"

  parent_id = aws_organizations_organizational_unit.production.id
}

resource "aws_organizations_organizational_unit" "core" {
  name = "Core"

  parent_id = local.organization_id
}

resource "aws_organizations_organizational_unit" "quarantine" {
  name = "Quarantine"

  parent_id = local.organization_id
}
