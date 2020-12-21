provider "aws" {
  region = "us-east-1"
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
