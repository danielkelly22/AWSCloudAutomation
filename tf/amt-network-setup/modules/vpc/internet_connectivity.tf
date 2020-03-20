locals {
  public_egress_subnets = var.vpc_details.public_subnets
  private_egress_subnets = toset([
    for subnet, type in var.vpc_details.nat_subnets
    : subnet
    if type == "nat"
  ])
  private_egress_dependent_subnets = flatten([
    for subnet in local.private_egress_subnets : [
      for dependent_subnet, nat_subnet in var.vpc_details.nat_subnets : {
        nat_subnet     = nat_subnet
        private_subnet = dependent_subnet
      }
      if subnet == nat_subnet
    ]
  ])

  any_public_egress = length(local.public_egress_subnets) == 0 ? [] : ["public-egress"]
}

#-----------------------------------
# Public Egress
#-----------------------------------
resource "aws_internet_gateway" "internet_gateways" {
  for_each = toset(local.any_public_egress)

  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    Name = "amt-${var.vpc_details.environment_affix}-internet_gateway"
  })
}

resource "aws_route_table" "egress_public" {
  for_each = toset(local.any_public_egress)

  vpc_id = aws_vpc.vpc.id

  # local route is created automatically

  dynamic "route" {
    for_each = var.internet_routable_cidr_blocks

    content {
      cidr_block = route.value
      gateway_id = aws_internet_gateway.internet_gateways[each.key].id
    }
  }

  dynamic "route" {
    for_each = var.private_egress_blocks

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
  route_table_id = aws_route_table.egress_public["public-egress"].id
}

#-----------------------------------
# Private Egress
#-----------------------------------
resource "aws_eip" "eips" {
  for_each = local.private_egress_subnets

  vpc = true

  tags = merge(var.tags, {
    Name = "amt-${var.vpc_details.environment_affix}-nat-gateway-eip"
  })
}

resource "aws_nat_gateway" "gateways" {
  for_each = local.private_egress_subnets

  allocation_id = aws_eip.eips[each.key].id
  subnet_id     = aws_subnet.subnets[each.key].id

  tags = merge(var.tags, {
    Name = "amt-${var.vpc_details.environment_affix}-nat-gateway"
  })
}

resource "aws_route_table" "egress_private" {
  for_each = local.private_egress_subnets

  vpc_id = aws_vpc.vpc.id

  dynamic "route" {
    for_each = var.internet_routable_cidr_blocks

    content {
      cidr_block     = route.value
      nat_gateway_id = aws_nat_gateway.gateways[each.key].id
    }
  }

  dynamic "route" {
    for_each = var.private_egress_blocks

    content {
      cidr_block         = route.value
      transit_gateway_id = var.transit_gateway_id
    }
  }

  tags = merge(var.tags, {
    Name = "amt-${var.vpc_details.environment_affix}-private-egress-routes"
  })

}

resource "aws_route_table_association" "egress_private_dependent_subnets" {
  for_each = { for x in local.private_egress_dependent_subnets : x.private_subnet => x.nat_subnet }

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.egress_private[each.value].id
}
