terraform {
  required_version = ">= 0.10.3"

  backend "s3" {
    bucket = "amtrust-tf-state"
    key = "us-east-1/vpc/uat_vpc/terraform.tfstate"
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

  name = "uat"

  cidr = "10.98.32.0/20"

  azs             = ["us-east-1a", "us-east-1a","us-east-1a","us-east-1a"
  ,"us-east-1b","us-east-1b","us-east-1b","us-east-1b"]
  private_subnets = ["10.98.32.0/23", "10.98.34.0/23","10.98.36.0/23","10.98.38.0/23"
  ,"10.98.40.0/23","10.98.42.0/23","10.98.44.0/23","10.98.46.0/23"]
  
  private_subnets_names=["WebSubnetAZ1","AppSubnetAZ1","DataSubnetAZ1","FreeSubnetAZ1",
  "WebSubnetAZ2","AppSubnetAZ2","DataSubnetAZ2","FreeSubnetAZ2"]


  assign_generated_ipv6_cidr_block = false
  enable_dns_hostnames =true
  enable_nat_gateway = false
  enable_internet_gateway = false

 

  tags = {
    Location= "EastUS1"
    BusinessUnit= "Claims"
    Environment= "uat"
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
    Name = "uat"
  }
}
/*
data "aws_ssm_parameter" "vpc_peer_tansit_1" {
    name = "transit-1-vpc"
}
module "peering_transit-1-uat" {
  source = "../../modules/peering"
  vpc_id = "${data.aws_ssm_parameter.vpc_peer_tansit_1.value}"
  peer_vpc_id="${module.vpc.vpc_id}"
  name = "transit-1-uat"
  tags = {
    Location= "EastUS1"
    BusinessUnit= "Claims"
    Environment= "Uat"
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
module "peering_shared-1-uat" {
  source = "../../modules/peering"
  vpc_id = "${data.aws_ssm_parameter.vpc_peer_shared_1.value}"
  peer_vpc_id="${module.vpc.vpc_id}"
  name = "shared-1-uat"
  tags = {
    Location= "EastUS1"
    BusinessUnit= "Claims"
    Environment= "Uat"
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