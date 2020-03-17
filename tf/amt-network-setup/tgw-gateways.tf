#-----------------------------------------------
# Primary
#-----------------------------------------------
# data "aws_subnet" "prod_az1" {
#   provider   = aws.prod
#   cidr_block = var.prod_subnet_ranges[1]
# }
# data "aws_subnet" "prod_az2" {
#   provider   = aws.prod
#   cidr_block = var.prod_subnet_ranges[6]
# }
# data "aws_subnet" "uat_az1" {
#   provider   = aws.uat
#   cidr_block = var.uat_subnet_ranges[1]
# }
# data "aws_subnet" "uat_az2" {
#   provider   = aws.uat
#   cidr_block = var.uat_subnet_ranges[4]
# }
# data "aws_subnet" "dev_az1" {
#   provider   = aws.dev
#   cidr_block = var.dev_subnet_ranges[1]
# }
# data "aws_subnet" "dev_az2" {
#   provider   = aws.dev
#   cidr_block = var.dev_subnet_ranges[6]
# }
# data "aws_subnet" "transit_az1" {
#   provider   = aws.shared
#   cidr_block = var.transit_subnet_ranges[1]
# }
# data "aws_subnet" "shared_az1" {
#   provider   = aws.shared
#   cidr_block = var.shared_subnet_ranges[0]
# }
# data "aws_subnet" "shared_az2" {
#   provider   = aws.shared
#   cidr_block = var.shared_subnet_ranges[1]
# }

# module "transit-gateway" {
#   source = "./modules/transitGateway"
#   providers = {
#     aws.shared = aws.shared
#     aws.dev    = aws.dev
#     aws.prod   = aws.prod
#     aws.uat    = aws.uat
#   }
#   dev_cidr           = var.dev_vpc_cidr
#   uat_cidr           = var.uat_vpc_cidr
#   prod_cidr          = var.prod_vpc_cidr
#   shared_cidr        = var.shared_vpc_cidr
#   transit_cidr       = var.transit_vpc_cidr
#   vpc_ids            = [module.prod_vpc.vpc_id, module.uat_vpc.vpc_id, module.dev_vpc.vpc_id, module.transit_vpc.vpc_id, module.shared_vpc.vpc_id]
#   prod_subnet_ids    = [data.aws_subnet.prod_az1.id, data.aws_subnet.prod_az2.id]
#   uat_subnet_ids     = [data.aws_subnet.uat_az1.id, data.aws_subnet.uat_az2.id]
#   dev_subnet_ids     = [data.aws_subnet.dev_az1.id, data.aws_subnet.dev_az2.id]
#   transit_subnet_ids = [data.aws_subnet.transit_az1.id]
#   shared_subnet_ids  = [data.aws_subnet.shared_az1.id, data.aws_subnet.shared_az2.id]
#   vpn_connection_id  = module.mainVPN.vpn_connection_id
#   env_name           = "Transit"
# }
module "tgw_tags" {
  providers = { aws = aws.shared }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.1"

  application_name     = var.networking_application_name
  business_unit        = var.networking_business_unit
  environment          = "transit"
  cost_center          = var.networking_cost_center
  application_owner    = var.networking_team_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

# module "tgw" {
#   providers = { aws = aws.shared }

#   source = "./modules/transit_gateway"

#   tags = module.tgw_tags.tags
# }

#-----------------------------------------------
# DR
#-----------------------------------------------
module "dr_tgw_tags" {
  providers = { aws = aws.shared_dr }

  source  = "tfe.amtrustgroup.com/AmTrust/tags/aws"
  version = ">= 0.3.1"

  application_name     = var.networking_application_name
  business_unit        = var.networking_business_unit
  environment          = "dr_transit"
  cost_center          = var.networking_cost_center
  application_owner    = var.networking_team_email
  infrastructure_owner = var.cloud_governance_email
  terraform_workspace  = var.terraform_workspace
}

module "dr_tgw" {
  providers = { aws = aws.shared_dr }

  source = "./modules/transit_gateway"

  tags = module.dr_tgw_tags.tags
}
