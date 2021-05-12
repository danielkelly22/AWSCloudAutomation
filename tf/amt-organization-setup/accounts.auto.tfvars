accounts = {
  amt-aws-smartcomm-dev = {
    name      = "smartcomm-dev"
    role_name = "OrganizationAccountAccessRole"
    ou_key    = "nonprod"
    email     = "AMT-AWS-SmartCommDev@amtrustgroup.com"
  }
  amt-aws-smartcomm-prod = {
    name      = "smartcomm-prod"
    role_name = "OrganizationAccountAccessRole"
    ou_key    = "production"
    email     = "AMT-AWS-SmartCommProd@amtrustgroup.com"
  }
  development = {
    name      = "Development"
    email     = "AMT-AWS-DevAcct@amtrustgroup.com"
    ou_key    = "nonprod"
    role_name = "DevelopmentRoot"
  }
  logarch = {
    name      = "Log Archive"
    email     = "AMT-AWS-LogArchAcct@amtrustgroup.com"
    ou_key    = "core"
    role_name = "LogArchRoot"
  }
  omniusnonprod = {
    name      = "omni:us Non-Production"
    email     = "AMT-AWS-OmnDevAcct@amtrustgroup.com"
    ou_key    = "nonprod"
    role_name = "OmniusNonProdRoot"
  }
  omniusprod = {
    name      = "omni:us Production"
    email     = "AMT-AWS-OmnProdAcct@amtrustgroup.com"
    ou_key    = "vendormanaged"
    role_name = "OmniusProdRoot"
  }
  production = {
    name      = "Production"
    email     = "AMT-AWS-ProductionAcct@amtrustgroup.com"
    ou_key    = "production"
    role_name = "ProductionRoot"
  }
  s3public = {
    name      = "Pulbic S3 Buckets"
    email     = "AMT-AWS-S3Public@amtrustgroup.com"
    ou_key    = "public"
    role_name = "S3PublicRoot"
  }
  sandbox = {
    name      = "Sandbox"
    email     = "AMT-AWS-SandboxAcct@amtrustgroup.com"
    ou_key    = "sandbox"
    role_name = "SandboxRoot"
  }
  security = {
    name      = "Security"
    email     = "AMT-AWS-SecurityAcct@amtrustgroup.com"
    ou_key    = "core"
    role_name = "SecurityRoot"
  }
  sharedsvc = {
    name      = "Shared Services"
    email     = "AMT-AWS-SharedSvcAcct@amtrustgroup.com"
    ou_key    = "core"
    role_name = "SharedSvcRoot"
  }
  staging = {
    name      = "Staging"
    email     = "AMT-AWS-StagingAcct@amtrustgroup.com"
    ou_key    = "production"
    role_name = "StagingRoot"
  }
  test = {
    name      = "Test"
    email     = "AMT-AWS-TestAcct@amtrustgroup.com"
    ou_key    = "nonprod"
    role_name = "TestRoot"
  }
}
