module "dr_tgw_rt_uat" {
  providers = { aws = aws.shared_dr }

  source = "./modules/transit_gateway_route_table"

  environment_affix             = var.uat_vpc_details.dr.environment_affix
  transit_gateway_id            = module.dr_tgw.tgw_id
  transit_gateway_attachment_id = module.dr_uat_vpc.transit_gateway_attachment_id

  attachment_routes = {
    # vpn = {
    #   cidr_blocks   = values(local.local_addresses)
    #   attachment_id = module.dr_vpn.attachment_id
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
    production  = var.prod_vpc_details.dr.cidr_block
  }

  tags = module.dr_tgw_tags.tags
}
