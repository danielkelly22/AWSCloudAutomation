terraform {
  required_version = ">= 0.10.3"

  backend "s3" {
    bucket = "amtrust-tf-state"
    key = "us-east-1/vpc/shared_services_vpc_2/terraform.tfstate"
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

  name = "shared-services-2"

  cidr = "10.203.248.0/23"

  azs             = ["us-east-1a"]
  private_subnets = ["10.203.248.0/23"]

  private_subnets_names=["SharedServicesSubnet"]
  public_subnets  = []


  assign_generated_ipv6_cidr_block = false
  enable_dns_hostnames =true

  enable_nat_gateway = false
  single_nat_gateway = false
  enable_internet_gateway=false

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
 
  vpc_tags = {
    Name = "shared-services-2"
  }
}
/*
module "peering" {
  source = "../../modules/peering"
  vpc_id = "vpc-04047aa5485bce344"
  peer_vpc_id="${module.vpc.vpc_id}"
  name = "transit-2-shared-2"
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
}*/