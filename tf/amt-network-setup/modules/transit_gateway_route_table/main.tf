locals {
  routes_flattened = flatten([
    for key, routes in var.attachment_routes : [
      for cidr_block in routes.cidr_blocks : {
        key           = key
        cidr_block    = cidr_block
        attachment_id = routes.attachment_id
      }
    ]
  ])
  attachment_routes = {
    for route in local.routes_flattened
    : "${route.key}-${route.cidr_block}" => route
  }
}

resource "aws_ec2_transit_gateway_route_table" "rt" {
  transit_gateway_id = var.transit_gateway_id

  tags = merge(var.tags, {
    Name = "amt-${var.environment_affix}-transit-route-table"
  })
}

resource "aws_ec2_transit_gateway_route_table_association" "association" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt.id
  transit_gateway_attachment_id  = var.transit_gateway_attachment_id
}


resource "aws_ec2_transit_gateway_route" "routes" {
  for_each = local.attachment_routes

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt.id
  destination_cidr_block         = each.value.cidr_block
  transit_gateway_attachment_id  = each.value.attachment_id
}

resource "aws_ec2_transit_gateway_route" "blackhole_routes" {
  for_each = var.blackhole_routes

  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt.id
  destination_cidr_block         = each.value
  blackhole                      = true
}
