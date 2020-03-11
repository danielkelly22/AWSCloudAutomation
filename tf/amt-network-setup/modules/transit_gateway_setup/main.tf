provider "aws" {}

provider "aws" {
  alias = "shared"
}

# The attachment from the VPC to the transit gateway. This must be accepted in the account in which the transit gateway is deployed.
resource "aws_ec2_transit_gateway_vpc_attachment" "attachment" {
  subnet_ids         = var.subnets
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = var.vpc_id

  transit_gateway_default_route_table_association = var.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_default_route_table_propagation

  # edit lifecycle of the default arguments above to supress odd behavior
  lifecycle {
    ignore_changes = [transit_gateway_default_route_table_association, transit_gateway_default_route_table_propagation]
  }

  tags = merge(var.tags, {
    Name                   = "amt-${var.environment_affix}-vpc-gateway-attachment"
    vpc-gateway-attachment = "requestor"
  })
}

locals {
  accepters = var.skip_gateway_attachment_acceptance == true ? {} : { tgw-in-different-account = true }
}

# This accepts the VPC's connection to the transit gateway.
resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "accepter" {
  provider = aws.shared

  for_each = local.accepters

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.attachment.id

  transit_gateway_default_route_table_association = var.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_default_route_table_propagation

  tags = merge(var.tags, {
    Name                   = "amt-${var.environment_affix}-vpc-gateway-attachment-accepter"
    vpc-gateway-attachment = "accepter"
  })
}

locals {
  hacky_way_to_depend_on_the_for_each = keys(aws_ec2_transit_gateway_vpc_attachment_accepter.accepter)
}


# Creates a route table attached to the transit gateway. This will be used for our environment.
resource "aws_ec2_transit_gateway_route_table" "routes" {
  provider = aws.shared

  transit_gateway_id = var.transit_gateway_id

  tags = merge(var.tags, {
    Name        = "amt-${var.environment_affix}-tgw-routes",
    required-by = join(",", local.hacky_way_to_depend_on_the_for_each)
  })

  # Note. This doesn't have any direct dependencies on the accepter, but will fail unless the accepter has completed.
  #depends_on = [aws_ec2_transit_gateway_vpc_attachment_accepter.accepter]
}

# Associates the route table to the VPC attachment
resource "aws_ec2_transit_gateway_route_table_association" "routes" {
  provider = aws.shared

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.routes.id
}

# Internet bound routes - Defaults to quad zeroes
resource "aws_ec2_transit_gateway_route" "internet_routes" {
  provider = aws.shared

  for_each = var.internet_routable_cidr_blocks

  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.routes.id
}

# Internal routes for AWS VPCs
resource "aws_ec2_transit_gateway_route" "aws_routes" {
  provider = aws.shared

  for_each = var.aws_routable_cidr_blocks

  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.routes.id
}

# Routes that should be sent to the VPC gateway attachment
resource "aws_ec2_transit_gateway_route" "vpn_routes" {
  provider = aws.shared

  for_each = var.vpn_routable_cidr_blocks

  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = var.vpn_transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.routes.id
}

# Routes that should be blackholed
resource "aws_ec2_transit_gateway_route" "blackhole_routes" {
  provider = aws.shared

  for_each = var.blackhole_cidr_blocks

  destination_cidr_block         = each.value
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.routes.id
}
