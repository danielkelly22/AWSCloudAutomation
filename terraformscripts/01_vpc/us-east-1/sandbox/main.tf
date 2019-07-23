terraform {
  required_version = ">= 0.10.3"

  backend "s3" {
    bucket = "amtrust-tf-state"
    key = "us-east-1/vpc/sandbox_vpc/terraform.tfstate"
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

  name = "sandbox"

  cidr = "10.203.252.0/22"

  azs             = ["us-east-1a", "us-east-1a", "us-east-1a", "us-east-1a"]
  private_subnets = ["10.203.252.0/24", "10.203.253.0/24","10.203.254.0/24", "10.203.255.0/24"]
  public_subnets  = []
  private_subnets_names=["WebSubnet","AppSubnet","DataSubnet","FreeSubnet"]
  
  assign_generated_ipv6_cidr_block = false
  enable_dns_hostnames =true

  enable_nat_gateway = false
  enable_internet_gateway = false

 

  tags = {
    Location= "EastUS1"
    BusinessUnit= "Claims"
    Environment= "sandbox"
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
    Name = "sandbox"
  }
}
/*
data "aws_ssm_parameter" "vpc_peer_requestid" {
    name = "transit-2-vpc"
}
module "peering" {
  source = "../../modules/peering"
  vpc_id = "${data.aws_ssm_parameter.vpc_peer_requestid.value}"
  peer_vpc_id="${module.vpc.vpc_id}"
  name = "transit-2-sandbox"
  tags = {
    Location= "EastUS1"
    BusinessUnit= "Claims"
    Environment= "sandbox"
    CostCenter= "AM00001"
    ApplicationName= "CPP"
    ApplicationOwner= "appteam@amtrustgroup.com"
    InfrastructureOwner= "cloudteam@amtrustgroup.com"
    AssetRole= "WebServer"
    MaintWindow= "SAT,23:00EST"
    SupportSLA= "Mo-Sa,6:00-23:00EST"
    BusinessContinuity= "C1"
  }

}*/