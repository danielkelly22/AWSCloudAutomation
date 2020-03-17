#-----------------------------------------------
# Primary
#-----------------------------------------------
module "tgw_rt_prod" {
  providers = { aws = aws.shared }

  source = "./modules/transit_gateway_route_table"

  environment_affix             = var.prod_vpc_details.primary.environment_affix
  transit_gateway_id            = module.tgw.tgw_id
  transit_gateway_attachment_id = module.prod_vpc.transit_gateway_attachment_id

  attachment_routes = {
    vpn = {
      cidr_blocks   = values(local.local_addresses)
      attachment_id = module.vpn.transit_gateway_attachment_id
    }
    internet-outbound = {
      cidr_blocks   = ["0.0.0.0/0"]
      attachment_id = module.transit_vpc.transit_gateway_attachment_id
    }
    shared-vpc = {
      cidr_blocks   = [var.shared_vpc_details.primary.cidr_block]
      attachment_id = module.shared_vpc.transit_gateway_attachment_id
    }
    transit-vpc = {
      cidr_blocks   = [var.transit_vpc_details.primary.cidr_block]
      attachment_id = module.transit_vpc.transit_gateway_attachment_id
    }
  }

  blackhole_routes = {
    development = var.dev_vpc_details.primary.cidr_block
    uat         = var.uat_vpc_details.primary.cidr_block
  }

  tags = module.tgw_tags.tags
}

#-----------------------------------------------
# DR
#-----------------------------------------------
module "dr_tgw_rt_prod" {
  providers = { aws = aws.shared_dr }

  source = "./modules/transit_gateway_route_table"

  environment_affix             = var.prod_vpc_details.dr.environment_affix
  transit_gateway_id            = module.dr_tgw.tgw_id
  transit_gateway_attachment_id = module.dr_prod_vpc.transit_gateway_attachment_id

  attachment_routes = {
    # vpn = {
    #   cidr_blocks   = values(local.local_addresses)
    #   attachment_id = module.dr_vpn.attachment_id
    #   is_blackhole  = false
    # }
    internet-outbound = {
      cidr_blocks   = ["0.0.0.0/0"]
      attachment_id = module.dr_transit_vpc.transit_gateway_attachment_id
    }
    shared-vpc = {
      cidr_blocks   = [var.shared_vpc_details.dr.cidr_block]
      attachment_id = module.dr_shared_vpc.transit_gateway_attachment_id
    }
    transit-vpc = {
      cidr_blocks   = [var.transit_vpc_details.dr.cidr_block]
      attachment_id = module.dr_transit_vpc.transit_gateway_attachment_id
    }
  }

  blackhole_routes = {
    development = var.dev_vpc_details.dr.cidr_block
    uat         = var.uat_vpc_details.dr.cidr_block
  }

  tags = module.dr_tgw_tags.tags
}
