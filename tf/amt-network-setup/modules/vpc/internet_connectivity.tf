locals {
  public_egress_subnets = var.vpc_details.public_subnets

  # This gets a set of only the fields with a type field of "nat" in the nat_subnets section.
  private_egress_subnets = toset([
    for subnet, type in var.vpc_details.nat_subnets
    : subnet
    if type == "nat"
  ])

  # Creates a flat list of the values in the nat_subnets section and matches them up to their subnet
  private_egress_dependent_subnets = flatten([
    for subnet in local.private_egress_subnets : [
      for dependent_subnet, nat_subnet in var.vpc_details.nat_subnets : {
        nat_subnet     = nat_subnet
        private_subnet = dependent_subnet
      }
      if subnet == nat_subnet
    ]
  ])

  # If there are no public subnets, then this is empty. Otherwise there is a record. This is
  # Since we only need one internet gateway, it's simpler than with the NAT gateways.
  any_public_egress = length(local.public_egress_subnets) == 0 ? [] : ["public-egress"]
}

#-----------------------------------
# Public Egress
#-----------------------------------
# Deploys one internet gateway if there are any public subnets in the VPC.
resource "aws_internet_gateway" "internet_gateways" {
  for_each = toset(local.any_public_egress)

  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    Name = "amt-${var.vpc_details.environment_affix}-internet_gateway"
  })
}

# If there is a public subnet, then create a public route table.
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

# If there are public subnets, associate the public route table to the subnets.
resource "aws_route_table_association" "egress_public" {
  for_each = local.public_egress_subnets

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.egress_public["public-egress"].id
}

#-----------------------------------
# Private Egress
#-----------------------------------
# Create an elastic IP address for each private egress subnet.
resource "aws_eip" "eips" {
  for_each = local.private_egress_subnets

  vpc = true

  tags = merge(var.tags, {
    Name = "amt-${var.vpc_details.environment_affix}-nat-gateway-eip"
  })
}

# Create a NAT gateway for each private egress subnet
resource "aws_nat_gateway" "gateways" {
  for_each = local.private_egress_subnets

  allocation_id = aws_eip.eips[each.key].id
  subnet_id     = aws_subnet.subnets[each.key].id

  tags = merge(var.tags, {
    Name = "amt-${var.vpc_details.environment_affix}-nat-gateway"
  })
}

# Create a route table for each private egress subnet
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

# Route each subnet to the private egress subnet specified.
# Note that this is the many-to-many relationship that we created in the 
# locals. It outputs a list of objects, but we need a map of objects for 
# it to work properly in Terraform. That's what we're doing in the for_each.
resource "aws_route_table_association" "egress_private_dependent_subnets" {
  for_each = { for x in local.private_egress_dependent_subnets : x.private_subnet => x.nat_subnet }

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.egress_private[each.value].id
}
