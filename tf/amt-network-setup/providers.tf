provider "aws" {
  region = "us-east-1"
}

#-----------------------------------------------
# Development
#-----------------------------------------------
provider "aws" {
  alias  = "dev"
  region = "us-east-1"
  assume_role {
    role_arn = var.organization_accounts.development.assume_role_arn
  }
}
provider "aws" {
  alias  = "dev_dr"
  region = "us-east-2"
  assume_role {
    role_arn = var.organization_accounts.development.assume_role_arn
  }
}

#-----------------------------------------------
# Production
#-----------------------------------------------
provider "aws" {
  alias  = "prod"
  region = "us-east-1"
  assume_role {
    role_arn = var.organization_accounts.production.assume_role_arn
  }
}
provider "aws" {
  alias  = "prod_dr"
  region = "us-east-2"
  assume_role {
    role_arn = var.organization_accounts.production.assume_role_arn
  }
}

#-----------------------------------------------
# Sandbox
#-----------------------------------------------
provider "aws" {
  alias  = "sandbox"
  region = "us-east-1"
  assume_role {
    role_arn = var.organization_accounts.sandbox.assume_role_arn
  }
}

#-----------------------------------------------
# Shared
#-----------------------------------------------
provider "aws" {
  alias  = "shared"
  region = "us-east-1"
  assume_role {
    role_arn = var.organization_accounts.shared.assume_role_arn
  }
}
provider "aws" {
  alias  = "shared_dr"
  region = "us-east-2"
  assume_role {
    role_arn = var.organization_accounts.shared.assume_role_arn
  }
}

#-----------------------------------------------
# UAT
#-----------------------------------------------
provider "aws" {
  alias  = "uat"
  region = "us-east-1"
  assume_role {
    role_arn = var.organization_accounts.uat.assume_role_arn
  }
}
provider "aws" {
  alias  = "uat_dr"
  region = "us-east-2"
  assume_role {
    role_arn = var.organization_accounts.uat.assume_role_arn
  }
}
