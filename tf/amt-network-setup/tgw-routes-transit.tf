#-----------------------------------------------
# Primary
#-----------------------------------------------
module "tgw_rt_transit" {
  providers = { aws = aws.shared }

  source = "./modules/transit_gateway_route_table"

  environment_affix             = var.transit_vpc_details.primary.environment_affix
  transit_gateway_id            = module.tgw.tgw_id
  transit_gateway_attachment_id = module.transit_vpc.transit_gateway_attachment_id

  attachment_routes = {
    vpn = {
      cidr_blocks   = values(local.local_addresses)
      attachment_id = module.vpn.transit_gateway_attachment_id
    }
    shared-vpc = {
      cidr_blocks   = [var.shared_vpc_details.primary.cidr_block]
      attachment_id = module.shared_vpc.transit_gateway_attachment_id
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
    cloudendure-replication-vpc = {
      cidr_blocks   = [var.shared_vpc_details.cloudendure_replication.cidr_block]
      attachment_id = module.shared_cloudendure_replication_vpc.transit_gateway_attachment_id
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
# DR
#-----------------------------------------------
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

  #   We want to block any 'isolated' subnet's cidr's. But we don't want to
  # block the jump host from having regular network access because it needs
  # to do things like copy backups into the environment.
  #   Although in the future, blocking jump host network access, but allowing
  # s3 and internet access, might be an even safer route.
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
