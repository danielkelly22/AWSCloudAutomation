accounts = {
  development = {
    name      = "Development"
    email     = "AMT-AWS-DevAcct@amtrustgroup.com"
    ou_key    = "nonprod"
    role_name = "DevelopmentRoot"
  },
  test = {
    name      = "Test"
    email     = "AMT-AWS-TestAcct@amtrustgroup.com"
    ou_key    = "nonprod"
    role_name = "TestRoot"
  },
  sandbox = {
    name      = "Sandbox"
    email     = "AMT-AWS-SandboxAcct@amtrustgroup.com"
    ou_key    = "sandbox"
    role_name = "SandboxRoot"
  },
  staging = {
    name      = "Staging"
    email     = "AMT-AWS-StagingAcct@amtrustgroup.com"
    ou_key    = "production"
    role_name = "StagingRoot"
  },
  production = {
    name      = "Production"
    email     = "AMT-AWS-ProductionAcct@amtrustgroup.com"
    ou_key    = "production"
    role_name = "ProductionRoot"
  },
  security = {
    name      = "Security"
    email     = "AMT-AWS-SecurityAcct@amtrustgroup.com"
    ou_key    = "core"
    role_name = "SecurityRoot"
  },
  logarch = {
    name      = "Log Archive"
    email     = "AMT-AWS-LogArchAcct@amtrustgroup.com"
    ou_key    = "core"
    role_name = "LogArchRoot"
  },
  sharedsvc = {
    name      = "Shared Services"
    email     = "AMT-AWS-SharedSvcAcct@amtrustgroup.com"
    ou_key    = "core"
    role_name = "SharedSvcRoot"
  },
  omniusprod = {
    name      = "omni:us Production"
    email     = "AMT-AWS-OmnProdAcct@amtrustgroup.com"
    ou_key    = "vendormanaged"
    role_name = "OmniusProdRoot"
  },
  omniusnonprod = {
    name      = "omni:us Non-Production"
    email     = "AMT-AWS-OmnDevAcct@amtrustgroup.com"
    ou_key    = "nonprod"
    role_name = "OmniusNonProdRoot"
  }
}
