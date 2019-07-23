terraform {
  required_version = ">= 0.10.3"

  backend "s3" {
      bucket = "amtrust-tf-state"
      key = "security_alerts/config_rules/terraform.tfstate"
      region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "config_rule" {
  source = "../modules/config_rule/"
  prefix_name="amtrust"

  tags = {
    Location= "EastUS1"
    BusinessUnit= "Claims"
    Environment= "Dev"
    CostCenter= "AM00001"
    ApplicationName= "CPP"
    ApplicationOwner= "appteam@amtrustgroup.com"
    InfrastructureOwner= "cloudteam@amtrustgroup.com"
    AssetRole= "WebServer"
    MaintWindow= "SAT 23:00EST"
    SupportSLA= "Mo-Sa 6:00-23:00EST"
    BusinessContinuity= "C1"
  }
}


