#-----------------------------------------------
# Sandbox VPC
#-----------------------------------------------
module "tgw_rt_sandbox" {
  providers = { aws = aws.sandbox }

  source = "./modules/transit_gateway_route_table"

  environment_affix             = var.sandbox_vpc_details.primary.environment_affix
  transit_gateway_id            = module.sandbox_tgw.tgw_id
  transit_gateway_attachment_id = module.sandbox_vpc.transit_gateway_attachment_id

  attachment_routes = {
    # vpn = {
    #   cidr_blocks   = values(local.local_addresses)
    #   attachment_id = module.vpn.transit_gateway_attachment_id
    # }
    internet-outbound = {
      cidr_blocks   = ["0.0.0.0/0"]
      attachment_id = module.sandbox_transit_vpc.transit_gateway_attachment_id
    }
    shared-vpc = {
      cidr_blocks   = [var.shared_vpc_details.sandbox.cidr_block]
      attachment_id = module.sandbox_shared_vpc.transit_gateway_attachment_id
    }
    transit-vpc = {
      cidr_blocks   = [var.transit_vpc_details.sandbox.cidr_block]
      attachment_id = module.sandbox_transit_vpc.transit_gateway_attachment_id
    }
  }

  blackhole_routes = {}
  tags             = module.sandbox_tgw_tags.tags
}


#-----------------------------------------------
# Shared VPC
#-----------------------------------------------
module "sandbox_tgw_rt_shared" {
  providers = { aws = aws.sandbox }

  source = "./modules/transit_gateway_route_table"

  environment_affix             = var.shared_vpc_details.sandbox.environment_affix
  transit_gateway_id            = module.sandbox_tgw.tgw_id
  transit_gateway_attachment_id = module.sandbox_shared_vpc.transit_gateway_attachment_id

  attachment_routes = {
    # vpn = {
    #   cidr_blocks   = values(local.local_addresses)
    #   attachment_id = module.vpn.sandbox_transit_gateway_attachment_id
    # }
    internet-outbound = {
      cidr_blocks   = ["0.0.0.0/0"]
      attachment_id = module.sandbox_transit_vpc.transit_gateway_attachment_id
    }
    transit-vpc = {
      cidr_blocks   = [var.transit_vpc_details.sandbox.cidr_block]
      attachment_id = module.sandbox_transit_vpc.transit_gateway_attachment_id
    }
    sandbox-vpc = {
      cidr_blocks   = [var.sandbox_vpc_details.primary.cidr_block]
      attachment_id = module.sandbox_vpc.transit_gateway_attachment_id
    }
  }
  tags = module.sandbox_tgw_tags.tags
}

#-----------------------------------------------
# Transit
#-----------------------------------------------
module "sandbox_tgw_rt_transit" {
  providers = { aws = aws.sandbox }

  source = "./modules/transit_gateway_route_table"

  environment_affix             = var.transit_vpc_details.sandbox.environment_affix
  transit_gateway_id            = module.sandbox_tgw.tgw_id
  transit_gateway_attachment_id = module.sandbox_transit_vpc.transit_gateway_attachment_id

  attachment_routes = {
    # vpn = {
    #   cidr_blocks   = values(local.local_addresses)
    #   attachment_id = module.vpn.transit_gateway_attachment_id
    # }
    shared-vpc = {
      cidr_blocks   = [var.shared_vpc_details.sandbox.cidr_block]
      attachment_id = module.sandbox_shared_vpc.transit_gateway_attachment_id
    }
    sandbox-vpc = {
      cidr_blocks   = [var.sandbox_vpc_details.primary.cidr_block]
      attachment_id = module.sandbox_vpc.transit_gateway_attachment_id
    }
  }
  tags = module.sandbox_tgw_tags.tags
}
