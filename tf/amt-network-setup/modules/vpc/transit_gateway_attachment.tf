locals {
  accepters = var.skip_gateway_attachment_acceptance == true ? {} : { tgw-in-different-account = true }
  transited_subnet_ids = [
    for key in var.vpc_details.transited_subnets : aws_subnet.subnets[key].id
  ]
}


# The attachment from the VPC to the transit gateway. This must be accepted in the account in which the transit gateway is deployed.
resource "aws_ec2_transit_gateway_vpc_attachment" "attachment" {
  subnet_ids         = local.transited_subnet_ids
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.vpc.id

  transit_gateway_default_route_table_association = var.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_default_route_table_propagation

  # edit lifecycle of the default arguments above to supress odd behavior
  lifecycle {
    ignore_changes = [transit_gateway_default_route_table_association, transit_gateway_default_route_table_propagation]
  }

  tags = merge(var.tags, {
    Name                   = "amt-${var.vpc_details.environment_affix}-vpc-gateway-attachment"
    vpc-gateway-attachment = "requestor"
  })
}

# This accepts the VPC's connection to the transit gateway.
resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "accepter" {
  provider = aws.shared

  for_each = local.accepters

  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.attachment.id

  transit_gateway_default_route_table_association = var.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_default_route_table_propagation

  tags = merge(var.tags, {
    Name                   = "amt-${var.vpc_details.environment_affix}-vpc-gateway-attachment-accepter"
    vpc-gateway-attachment = "accepter"
  })

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.attachment]
}

data "null_data_source" "hacky_way_to_ensure_that_the_accepter_completes" {
  inputs = {
    this_is_the_hacky_part = join(",", keys(aws_ec2_transit_gateway_vpc_attachment_accepter.accepter))
    tgw_attachment_id      = aws_ec2_transit_gateway_vpc_attachment.attachment.id
  }
}
