terraform {
  required_version = ">= 0.10.3"
  backend "s3" {
    bucket = "amtrust-tf-state"
    key = "us-east-1/vpc/transit-3-gateway/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-2"
}

module "transit-gateway" {
  source = "../../modules/transit-gateway/"
  vpc_names=["prod-dr"]
  vpc_ids = ["vpc-0e04e4a85e6ea6b5e","vpc-0c281a61ca9d78e3b"]
  subnet_ids ={
  "vpc-0e04e4a85e6ea6b5e" = ["subnet-01b9aaeafa84c3947","subnet-0e31b5146272b46a8"]
  "vpc-0c281a61ca9d78e3b" = ["subnet-0f3aec6dcbe78dd20"]
  }
    name = "transit-3-gateway"
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
  name="transit-3-gateway"
}