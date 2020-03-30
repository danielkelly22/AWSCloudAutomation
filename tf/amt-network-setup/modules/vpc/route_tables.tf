# This is the default route table. Any subnet not specified as a public or private
# subnet will receive this route.
resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  # "local" route is automatically created on the default route table.

  dynamic "route" {
    for_each = var.internet_routable_cidr_blocks

    content {
      cidr_block         = route.value
      transit_gateway_id = var.transit_gateway_id
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
    Name    = "amt-${var.vpc_details.environment_affix}-default-routes"
    discard = data.null_data_source.hacky_way_to_ensure_that_the_accepter_completes.outputs.tgw_attachment_id
  })
}
