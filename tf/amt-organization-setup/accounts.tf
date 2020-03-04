resource "aws_organizations_account" "development" {
  name      = "Development"
  email     = "AMT-AWS-DevAcct@amtrustgroup.com"
  parent_id = aws_organizations_organizational_unit.nonprod.id

  role_name = "DevelopmentRoot"
  lifecycle {
    ignore_changes = [role_name]
  }
}

resource "aws_organizations_account" "test" {
  name      = "Test"
  email     = "AMT-AWS-TestAcct@amtrustgroup.com"
  parent_id = aws_organizations_organizational_unit.nonprod.id

  role_name = "TestRoot"
  lifecycle {
    ignore_changes = [role_name]
  }
}

resource "aws_organizations_account" "sandbox" {
  name      = "Sandbox"
  email     = "AMT-AWS-SandboxAcct@amtrustgroup.com"
  parent_id = aws_organizations_organizational_unit.sandbox.id

  role_name = "SandboxRoot"
  lifecycle {
    ignore_changes = [role_name]
  }
}

resource "aws_organizations_account" "staging" {
  name      = "Staging"
  email     = "AMT-AWS-StagingAcct@amtrustgroup.com"
  parent_id = aws_organizations_organizational_unit.production.id

  role_name = "StagingRoot"
  lifecycle {
    ignore_changes = [role_name]
  }
}

resource "aws_organizations_account" "production" {
  name      = "Production"
  email     = "AMT-AWS-ProductionAcct@amtrustgroup.com"
  parent_id = aws_organizations_organizational_unit.production.id

  role_name = "ProductionRoot"
  lifecycle {
    ignore_changes = [role_name]
  }
}

resource "aws_organizations_account" "security" {
  name      = "Security"
  email     = "AMT-AWS-SecurityAcct@amtrustgroup.com"
  parent_id = aws_organizations_organizational_unit.core.id

  role_name = "SecurityRoot"
  lifecycle {
    ignore_changes = [role_name]
  }
}

resource "aws_organizations_account" "logarch" {
  name      = "Log Archive"
  email     = "AMT-AWS-LogArchAcct@amtrustgroup.com"
  parent_id = aws_organizations_organizational_unit.core.id

  role_name = "LogArchRoot"
  lifecycle {
    ignore_changes = [role_name]
  }
}

resource "aws_organizations_account" "sharedsvc" {
  name      = "Shared Services"
  email     = "AMT-AWS-SharedSvcAcct@amtrustgroup.com"
  parent_id = aws_organizations_organizational_unit.core.id

  role_name = "SharedSvcRoot"
  lifecycle {
    ignore_changes = [role_name]
  }
}

resource "aws_organizations_account" "omnius_production" {
  name      = "omni:us Production"
  email     = "AMT-AWS-OmnProdAcct@amtrustgroup.com"
  parent_id = aws_organizations_organizational_unit.vendormanaged.id

  role_name = "OmniusProdRoot"
  lifecycle {
    ignore_changes = [role_name]
  }
}

resource "aws_organizations_account" "omnius_nonprod" {
  name      = "omni:us Non-Production"
  email     = "AMT-AWS-OmnDevAcct@amtrustgroup.com"
  parent_id = aws_organizations_organizational_unit.nonprod.id

  role_name = "OmniusNonProdRoot"
  lifecycle {
    ignore_changes = [role_name]
  }
}
