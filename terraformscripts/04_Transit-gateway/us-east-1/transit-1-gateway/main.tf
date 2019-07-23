terraform {
  required_version = ">= 0.10.3"
  backend "s3" {
    bucket = "amtrust-tf-state"
    key = "us-east-1/vpc/transit-1-gateway/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "transit-gateway" {
  source = "../../modules/transit-gateway/"
  vpc_names=["dev","prod","uat","shared-services-1","transit-1"]
  vpc_ids = ["vpc-044532e407ebe3d13","vpc-0c2e1250ace5f0f75","vpc-0882371bb3cf3fad2",
  "vpc-071910d0a8f6a3eeb","vpc-02e4f20a27bf48536"]
  subnet_ids ={
  "vpc-044532e407ebe3d13" = ["subnet-09af53d4e31b091eb","subnet-0f43b847165284782"],
  "vpc-0c2e1250ace5f0f75" = ["subnet-030d65122eb1a7e25","subnet-0e3123b83e2c4e7fa"],
  "vpc-0882371bb3cf3fad2" = ["subnet-06a21058000bf0b2a","subnet-0f23d86c03ba405a8"],
  "vpc-071910d0a8f6a3eeb" = ["subnet-0f869ef378a11f522","subnet-001d9a728a0d946a4"]
  "vpc-02e4f20a27bf48536" = ["subnet-05f88c467d2918994"]
  }
    name = "transit-1-gateway"
    tags = {
    Location= "EastUS1"
    BusinessUnit= "Claims"
    Environment= "Dev"
    CostCenter= "AM00001"
    ApplicationName= "CPP"
    ApplicationOwner= "appteam@amtrustgroup.com"
    InfrastructureOwner= "cloudteam@amtrustgroup.com"
    AssetRole= "WebServer"
    MaintWindow= "SAT,23:00EST"
    SupportSLA= "Mo-Sa,6:00-23:00EST"
    BusinessContinuity= "C1"
  }
  name="transit-1-gateway"
}