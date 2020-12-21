#-----------------------------------------------
# Primary
#-----------------------------------------------
module "tgw_rt_shared" {
  providers = { aws = aws.shared }

  source = "./modules/transit_gateway_route_table"

  environment_affix             = var.shared_vpc_details.primary.environment_affix
  transit_gateway_id            = module.tgw.tgw_id
  transit_gateway_attachment_id = module.shared_vpc.transit_gateway_attachment_id

  attachment_routes = {
    vpn = {
      cidr_blocks   = values(local.local_addresses)
      attachment_id = module.vpn.transit_gateway_attachment_id
    }
    internet-outbound = {
      cidr_blocks   = ["0.0.0.0/0"]
      attachment_id = module.transit_vpc.transit_gateway_attachment_id
    }
    transit-vpc = {
      cidr_blocks   = [var.transit_vpc_details.primary.cidr_block]
      attachment_id = module.transit_vpc.transit_gateway_attachment_id
    }
    dev-vpc = {
      cidr_blocks   = [var.dev_vpc_details.primary.cidr_block]
      attachment_id = module.dev_vpc.transit_gateway_attachment_id
    }
    uat-vpc = {
      cidr_blocks   = [var.uat_vpc_details.primary.cidr_block]
      attachment_id = module.uat_vpc.transit_gateway_attachment_id
    }
    prod-vpc = {
      cidr_blocks   = [var.prod_vpc_details.primary.cidr_block]
      attachment_id = module.prod_vpc.transit_gateway_attachment_id
    }
  }

  blackhole_routes = {
    for k, v in module.shared_drtest_vpc.isolated_subnet_defs :
      k => cidrsubnet(
        var.shared_vpc_details.drtest.cidr_block,
        v.cidr.newbits,
        v.cidr.netnum
      )
  }

  tags = module.tgw_tags.tags
}


#-----------------------------------------------
# cloudendure_replication
#-----------------------------------------------
module "tgw_rt_shared_cloudendure_replication" {
  providers = { aws = aws.shared }

  source = "./modules/transit_gateway_route_table"

  environment_affix             = var.shared_vpc_details.cloudendure_replication.environment_affix
  transit_gateway_id            = module.tgw.tgw_id
  transit_gateway_attachment_id = module.shared_cloudendure_replication_vpc.transit_gateway_attachment_id

  attachment_routes = {
    vpn = {
      cidr_blocks   = values(local.local_addresses)
      attachment_id = module.vpn.transit_gateway_attachment_id
    }
    internet-outbound = {
      cidr_blocks   = ["0.0.0.0/0"]
      attachment_id = module.transit_vpc.transit_gateway_attachment_id
    }
    transit-vpc = {
      cidr_blocks   = [var.transit_vpc_details.primary.cidr_block]
      attachment_id = module.transit_vpc.transit_gateway_attachment_id
    }
    dev-vpc = {
      cidr_blocks   = [var.dev_vpc_details.primary.cidr_block]
      attachment_id = module.dev_vpc.transit_gateway_attachment_id
    }
    uat-vpc = {
      cidr_blocks   = [var.uat_vpc_details.primary.cidr_block]
      attachment_id = module.uat_vpc.transit_gateway_attachment_id
    }
    prod-vpc = {
      cidr_blocks   = [var.prod_vpc_details.primary.cidr_block]
      attachment_id = module.prod_vpc.transit_gateway_attachment_id
    }
  }

  blackhole_routes = {
    for k, v in module.shared_drtest_vpc.isolated_subnet_defs :
      k => cidrsubnet(
        var.shared_vpc_details.drtest.cidr_block,
        v.cidr.newbits,
        v.cidr.netnum
      )
  }

  tags = module.tgw_tags.tags
}


#-----------------------------------------------
# drtest (jump only)
#-----------------------------------------------
module "tgw_rt_shared_drtest" {
  providers = { aws = aws.shared }

  source = "./modules/transit_gateway_route_table"

  environment_affix             = var.shared_vpc_details.drtest.environment_affix
  transit_gateway_id            = module.tgw.tgw_id
  transit_gateway_attachment_id = module.shared_drtest_vpc.transit_gateway_attachment_id

  attachment_routes = {
    vpn = {
      cidr_blocks   = values(local.local_addresses)
      attachment_id = module.vpn.transit_gateway_attachment_id
    }
    internet-outbound = {
      cidr_blocks   = ["0.0.0.0/0"]
      attachment_id = module.transit_vpc.transit_gateway_attachment_id
    }
  }

  blackhole_routes = {
    sandbox = var.sandbox_vpc_details.primary.cidr_block
    development = var.dev_vpc_details.primary.cidr_block
    development_dr = var.dev_vpc_details.dr.cidr_block
    production  = var.prod_vpc_details.primary.cidr_block
    production_dr  = var.prod_vpc_details.dr.cidr_block
    uat         = var.uat_vpc_details.primary.cidr_block
    uat_dr      = var.uat_vpc_details.dr.cidr_block
  }

  tags = module.tgw_tags.tags
}



#-----------------------------------------------
# DR
#-----------------------------------------------
module "dr_tgw_rt_shared" {
  providers = { aws = aws.shared_dr }

  source = "./modules/transit_gateway_route_table"

  environment_affix             = var.shared_vpc_details.dr.environment_affix
  transit_gateway_id            = module.dr_tgw.tgw_id
  transit_gateway_attachment_id = module.dr_shared_vpc.transit_gateway_attachment_id

  attachment_routes = {
    # vpn = {
    #   cidr_blocks   = values(local.local_addresses)
    #   attachment_id = module.dr_vpn.attachment_id
    # }
    # internet-outbound = {
    #   cidr_blocks   = ["0.0.0.0/0"]
    #   attachment_id = module.dr_transit_vpc.transit_gateway_attachment_id
    # }
    transit-vpc = {
      cidr_blocks   = [var.transit_vpc_details.dr.cidr_block]
      attachment_id = module.dr_transit_vpc.transit_gateway_attachment_id
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

  blackhole_routes = {
    for k, v in module.shared_drtest_vpc.isolated_subnet_defs :
      k => cidrsubnet(
        var.shared_vpc_details.drtest.cidr_block,
        v.cidr.newbits,
        v.cidr.netnum
      )
  }

  tags = module.dr_tgw_tags.tags
}
