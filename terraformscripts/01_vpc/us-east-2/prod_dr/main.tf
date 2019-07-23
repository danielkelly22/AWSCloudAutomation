terraform {
  required_version = ">= 0.10.3"

  backend "s3" {
    bucket = "amtrust-tf-state"
    key = "us-east-2/vpc/prod_dr_vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-2"
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

  name = "prod_dr"

  cidr = "10.99.48.0/20"

 azs             = ["us-east-2a", "us-east-2a","us-east-2a","us-east-2a"
  ,"us-east-2b","us-east-2b","us-east-2b","us-east-2b"]
  private_subnets = ["10.99.48.0/23", "10.99.50.0/23","10.99.52.0/23","10.99.54.0/23"
  ,"10.99.56.0/23","10.99.58.0/23","10.99.60.0/23","10.99.62.0/23"]
  
  private_subnets_names=["WebSubnetAZ1","AppSubnetAZ1","DataSubnetAZ1","FreeSubnetAZ1",
  "WebSubnetAZ2","AppSubnetAZ2","DataSubnetAZ2","FreeSubnetAZ2"]

  assign_generated_ipv6_cidr_block = false

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
    Name = "prod-dr"
  }
}
/*
data "aws_ssm_parameter" "vpc_peer_tansit_3" {
    name = "transit-3-vpc"
}
module "peering" {
  source = "../../modules/peering"
  vpc_id = "${data.aws_ssm_parameter.vpc_peer_tansit_3.value}"
  peer_vpc_id="${module.vpc.vpc_id}"
  name = "trans3-prod-dr"
  tags = {
    Location= "EastUS1"
    BusinessUnit= "Claims"
    Environment= "prod"
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
*/