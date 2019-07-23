terraform {
  required_version = ">= 0.10.3"
  backend "s3" {
    bucket = "amtrust-tf-state"
    key = "us-east-1/vpc/transit-gateway/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "transit-gateway" {
  source = "../../modules/transit-gateway/"
  vpc_names=["dev,prod,uat"]
  vpc_ids = ["vpc-044532e407ebe3d13"]
  subnet_ids ={
  "vpc-044532e407ebe3d13" = ["subnet-09af53d4e31b091eb",
                             "subnet-0f43b847165284782"]
  }
    name = "transit-1-dev"
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
  name="transit-gateway"
}