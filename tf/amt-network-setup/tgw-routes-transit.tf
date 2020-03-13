module "dr_tgw_rt_transit" {
  providers = { aws = aws.shared_dr }

  source = "./modules/transit_gateway_route_table"

  environment_affix             = var.transit_vpc_details.dr.environment_affix
  transit_gateway_id            = module.dr_tgw.tgw_id
  transit_gateway_attachment_id = module.dr_transit_vpc.transit_gateway_attachment_id

  attachment_routes = {
    # vpn = {
    #   cidr_blocks   = values(local.local_addresses)
    #   attachment_id = module.dr_vpn.attachment_id
    # }
    shared-vpc = {
      cidr_blocks   = [var.shared_vpc_details.dr.cidr_block]
      attachment_id = module.dr_shared_vpc.transit_gateway_attachment_id
    }
    dev-vpc = {
      cidr_blocks   = [var.dev_vpc_details.dr.cidr_block]
      attachment_id = module.dr_dev_vpc.transit_gateway_attachment_id
    }
    uat-vpc = {
      cidr_blocks   = [var.uat_vpc_details.dr.cidr_block]
      attachment_id = module.dr_uat_vpc.transit_gateway_attachment_id
    }
    prod-vpc = {
      cidr_blocks   = [var.prod_vpc_details.dr.cidr_block]
      attachment_id = module.dr_prod_vpc.transit_gateway_attachment_id
    }
  }

  tags = module.dr_tgw_tags.tags
}
