terraform {
  required_version = ">= 0.10.3"

  backend "s3" {
    bucket = "amtrust-tf-state"
    key = "us-east-1/vpc/prod_vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}


module "dhcp_option_set" {
  source = "../../modules/dhcp_option_set/"

  vpc_id = "${module.vpc.vpc_id}"
}

module "flow_logs" {
  source = "../../modules/flow_logs/"

  vpc_id = "${module.vpc.vpc_id}"
  S3_flow_logs="amtrust-vpc-flow-logs"
}


module "vpc" {
  source = "../../modules/vpc"

  name = "prod"

  cidr = "10.98.48.0/20"

  azs             = ["us-east-1a", "us-east-1a","us-east-1a","us-east-1a"
  ,"us-east-1b","us-east-1b","us-east-1b","us-east-1b"]
  private_subnets = ["10.98.48.0/23", "10.98.50.0/23","10.98.52.0/23","10.98.54.0/23"
  ,"10.98.56.0/23","10.98.58.0/23","10.98.60.0/23","10.98.62.0/23"]
  
  private_subnets_names=["WebSubnetAZ1","AppSubnetAZ1","DataSubnetAZ1","FreeSubnetAZ1",
  "WebSubnetAZ2","AppSubnetAZ2","DataSubnetAZ2","FreeSubnetAZ2"]

  public_subnets  = []

  assign_generated_ipv6_cidr_block = false
  enable_dns_hostnames =true

  enable_nat_gateway = false
  enable_internet_gateway = false

 

  tags = {
    Location= "EastUS1"
    BusinessUnit= "Claims"
    Environment= "prod"
    CostCenter= "AM00001"
    ApplicationName= "CPP"
    ApplicationOwner= "appteam@amtrustgroup.com"
    InfrastructureOwner= "cloudteam@amtrustgroup.com"
    AssetRole= "WebServer"
    MaintWindow= "SAT 23:00EST"
    SupportSLA= "Mo-Sa 6:00-23:00EST"
    BusinessContinuity= "C1"
  }
 
  vpc_tags = {
    Name = "prod"
  }
}
/*
data "aws_ssm_parameter" "vpc_peer_tansit_1" {
    name = "transit-1-vpc"
}
module "peering_transit-1-prod" {
  source = "../../modules/peering"
  vpc_id = "${data.aws_ssm_parameter.vpc_peer_tansit_1.value}"
  peer_vpc_id="${module.vpc.vpc_id}"
  name = "transit-1-prod"
  tags = {
    Location= "EastUS1"
    BusinessUnit= "Claims"
    Environment= "Prod"
    CostCenter= "AM00001"
    ApplicationName= "CPP"
    ApplicationOwner= "appteam@amtrustgroup.com"
    InfrastructureOwner= "cloudteam@amtrustgroup.com"
    AssetRole= "WebServer"
    MaintWindow= "SAT,23:00EST"
    SupportSLA= "Mo-Sa,6:00-23:00EST"
    BusinessContinuity= "C1"
  }

}
data "aws_ssm_parameter" "vpc_peer_shared_1" {
    name = "shared-services-1-vpc"
}
module "peering_shared-1-prod" {
  source = "../../modules/peering"
  vpc_id = "${data.aws_ssm_parameter.vpc_peer_shared_1.value}"
  peer_vpc_id="${module.vpc.vpc_id}"
  name = "shared-1-prod"
  tags = {
    Location= "EastUS1"
    BusinessUnit= "Claims"
    Environment= "Prod"
    CostCenter= "AM00001"
    ApplicationName= "CPP"
    ApplicationOwner= "appteam@amtrustgroup.com"
    InfrastructureOwner= "cloudteam@amtrustgroup.com"
    AssetRole= "WebServer"
    MaintWindow= "SAT 23:00EST"
    SupportSLA= "Mo-Sa 6:00-23:00EST"
    BusinessContinuity= "C1"
  }

}*/