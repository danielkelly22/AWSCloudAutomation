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
  private_egress_cidr_blocks = flatten([
    for route_key, cidr_block in var.internet_routable_cidr_blocks : [
      for subnet, subnet_type in local.public_egress_subnets : {
        cidr_block    = cidr_block
        public_subnet = subnet
      }
    ]
  ])
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
  route_table_id = aws_route_table.egress_public[each.key].id
}

resource "aws_route_table" "egress_private" {
  for_each = local.private_egress_subnets

  vpc_id = aws_vpc.vpc.id

  dynamic "route" {
    for_each = local.private_egress_cidr_blocks

    content {
      cidr_block     = route.value.cidr_block
      nat_gateway_id = aws_nat_gateway.gateways[route.value.public_subnet].id
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

resource "aws_route_table_association" "egress_private" {
  for_each = local.private_egress_subnets

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.egress_private[each.key].id
}

