terraform {
  required_version = ">= 0.10.3"
  backend "s3" {
    bucket = "amtrust-tf-state"
    key = "us-east-1/vpc/transit-2-gateway/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "transit-gateway" {
  source = "../../modules/transit-gateway/"
  vpc_names=["sandbox","shared-services-2","transit-2"]
  vpc_ids = ["vpc-0edbc37828a8ca3a0","vpc-0a7c2f469ac5ee160","vpc-04047aa5485bce344"]
  subnet_ids ={
  "vpc-0edbc37828a8ca3a0" = ["subnet-0d4e9b487f4fc09bf"],
  "vpc-0a7c2f469ac5ee160" = ["subnet-0ccd2b6a3fd9e8686"],
  "vpc-04047aa5485bce344" = ["subnet-0dcae294224da453f"]
  }
    name = "transit-2-gateway"
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
  name="transit-2-gateway"
}