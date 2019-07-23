terraform {
  required_version = ">= 0.10.3"

  backend "s3" {
    bucket = "amtrust-tf-state"
    key = "us-east-2/vpc/mgmt_transit_vpc_3/terraform.tfstate"
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

  name = "transit-3"

  cidr = "10.99.8.0/23"

  azs             = ["us-east-2a",]
  private_subnets = ["10.99.8.0/24"]
  public_subnets  = [ "10.99.9.0/24"]

  private_subnets_names=["PrivatePeeringSubnet"]
  public_subnets_names=["PublicPeeringSubnet"]
  assign_generated_ipv6_cidr_block = false

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_internet_gateway=true

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
    Name = "transit-3"
  }
}
