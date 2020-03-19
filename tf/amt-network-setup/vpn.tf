#-----------------------------------------------
# Primary
#-----------------------------------------------
module "vpn" {
  providers = {
    aws = aws.shared
  }

  source = "./modules/vpn"

  environment_affix  = "shared"
  transit_gateway_id = module.tgw.tgw_id
  tags               = module.shared_tags.tags
}

#-----------------------------------------------
# DR
#-----------------------------------------------
# To Do
