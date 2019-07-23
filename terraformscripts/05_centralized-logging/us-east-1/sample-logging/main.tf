terraform {
  required_version = ">= 0.10.3"
  backend "s3" {
    bucket = "amtrust-tf-state"
    key = "us-east-1/centralized-logging/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "centralized-logging" {
    source = "../../modules/centralized-logging/"
    stack_name="centralized-logging-amtrust"
    DOMAINNAME = "centralizedlogging"
    DomainAdminEmail="AmTrustCloudTeam@amtrustgroup.com"
    CognitoAdminEmail="AmTrustCloudTeam@amtrustgroup.com"
    ClusterSize="Small"
    DemoTemplate="Yes"
    SpokeAccounts=""
    DemoVPC="10.98.16.0/20"
    DemoSubnet="10.98.16.0/23"
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