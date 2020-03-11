provider "aws" {}

provider "aws" {
  alias = "transit"
}

resource "aws_vpc" "vpc" {
  cidr_block                       = var.vpc_details.cidr_block
  instance_tenancy                 = var.vpc_defaults.instance_tenancy
  enable_dns_hostnames             = var.vpc_defaults.enable_dns_hostnames
  enable_dns_support               = var.vpc_defaults.enable_dns_support
  enable_classiclink               = var.vpc_defaults.enable_classiclink
  enable_classiclink_dns_support   = var.vpc_defaults.enable_classiclink_dns_support
  assign_generated_ipv6_cidr_block = var.vpc_defaults.assign_generated_ipv6_cidr_block

  tags = merge(var.tags, {
    Name        = "amt-${var.vpc_details.environment_affix}-vpc"
    environment = var.vpc_details.environment_affix
  })
}

resource "aws_subnet" "subnets" {
  for_each = var.vpc_details.subnets

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.value.availability_zone
  cidr_block        = cidrsubnet(var.vpc_details.cidr_block, each.value.cidr.newbits, each.value.cidr.netnum)
  tags = merge(var.tags, {
    Name        = each.key
    environment = var.vpc_details.environment_affix
  })
}

# overriding default security group, because it allows all ingress traffic
resource "aws_default_security_group" "default_security_group" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    Name  = "amt-${var.vpc_details.environment_affix}-vpc-default-security-group"
    notes = "This space is intentionally left blank."
  })
}


resource "aws_ram_resource_share" "subnets" {
  for_each = var.vpc_details.subnet_shares

  name                      = each.key
  allow_external_principals = each.value.allow_external_principals

  tags = merge(var.tags, {
    Name = "amt-${var.vpc_details.environment_affix}-ram-subnet-to-${each.value.target_name}"
  })
}

resource "aws_ram_principal_association" "subnet" {
  for_each = var.vpc_details.subnet_shares

  principal          = each.value.principal
  resource_share_arn = aws_ram_resource_share.subnets[each.key].arn
}

locals {
  subnet_shares_flat = flatten([
    for share_key, share in var.vpc_details.subnet_shares : [
      for subnet_key, subnet in share.subnets : {
        share_key  = share_key
        subnet_key = subnet_key
      }
    ]
  ])
}

resource "aws_ram_resource_association" "subnet_associations" {
  for_each = {
    for share in local.subnet_shares_flat : "${share.share_key}.${share.subnet_key}" => share
  }

  resource_arn       = aws_subnet.subnets[each.value.subnet_key].arn
  resource_share_arn = aws_ram_resource_share.subnets[each.value.share_key].arn
}

locals {
  transit_subnet_ids = [
    for subnet in var.vpc_details.transited_subnets :
    aws_subnet.subnets[subnet].id
  ]
}


#-----------------------------------
# Internet Connectivity
#-----------------------------------
locals {
  public_egress_subnets = {
    for key in keys(var.vpc_details.internet_connected_subnets)
    : key => var.vpc_details.internet_connected_subnets[key]
    if var.vpc_details.internet_connected_subnets[key] == "public"
  }
  private_egress_subnets = {
    for key in keys(var.vpc_details.internet_connected_subnets)
    : key => var.vpc_details.internet_connected_subnets[key]
    if var.vpc_details.internet_connected_subnets[key] == "private"
  }
}

resource "aws_eip" "eips" {
  for_each = local.public_egress_subnets

  vpc = true

  tags = merge(var.tags, {
    Name = "amt-${var.vpc_details.environment_affix}-nat-gateway-eip"
  })
}
resource "aws_nat_gateway" "gateways" {
  for_each = local.public_egress_subnets

  allocation_id = aws_eip.eips[each.key].id
  subnet_id     = aws_subnet.subnets[each.key].id

  tags = merge(var.tags, {
    Name = "amt-${var.vpc_details.environment_affix}-nat-gateway"
  })
}

resource "aws_internet_gateway" "internet_gateways" {
  for_each = local.public_egress_subnets

  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    Name = "amt-${var.vpc_details.environment_affix}-internet_gateway"
  })
}

resource "aws_route_table" "egress_public" {
  for_each = local.public_egress_subnets

  vpc_id = aws_vpc.vpc.id

  dynamic "route" {
    for_each = var.internet_egress_routes

    content {
      cidr_block = route.value
      gateway_id = aws_internet_gateway.internet_gateways[each.key].id
    }
  }

  dynamic "route" {
    for_each = var.private_egress_routes

    content {
      cidr_block         = route.value
      transit_gateway_id = var.transit_gateway_id
    }
  }

  tags = merge(var.tags, {
    Name = "amt-${var.vpc_details.environment_affix}-public-egress-routes"
  })
}

resource "aws_route_table_association" "egress_public" {
  for_each = local.public_egress_subnets

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.egress_public[each.key].id
}

resource "aws_route_table" "egress_private" {
  for_each = local.private_egress_subnets

  vpc_id = aws_vpc.vpc.id

  dynamic "route" {
    for_each = flatten([
      for route_key, cidr_block in var.internet_egress_routes : [
        for subnet, subnet_type in local.public_egress_subnets : {
          cidr_block    = cidr_block
          public_subnet = subnet
        }
      ]
    ])

    content {
      cidr_block     = route.value.cidr_block
      nat_gateway_id = aws_nat_gateway.gateways[route.value.public_subnet].id
    }
  }

  dynamic "route" {
    for_each = var.private_egress_routes

    content {
      cidr_block         = route.value
      transit_gateway_id = var.transit_gateway_id
    }
  }

  tags = merge(var.tags, {
    Name = "amt-${var.vpc_details.environment_affix}-private-egress-routes"
  })

}

resource "aws_route_table_association" "egress_private" {
  for_each = local.private_egress_subnets

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.egress_private[each.key].id
}


# resource "aws_route_table_association" "egress_public_rt_association" {
#   subnet_id      = aws_subnet.TransitPublicPeeringSubnetA.id
#   route_table_id = aws_route_table.egress_public_rt.id
# }


# resource "aws_route_table" "egress_private_rt" {
#   vpc_id = aws_vpc.vpc.id
#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.gw_az_a.id
#   }
#   tags = {
#     Name = "${var.env_name}EgressPrivateRT"
#   }
# }
# resource "aws_route_table_association" "egress_private_rt_association" {
#   subnet_id      = aws_subnet.TransitPrivatePeeringSubnetA.id
#   route_table_id = aws_route_table.egress_private_rt.id
# }
