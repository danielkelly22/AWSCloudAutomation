locals {
  s3_endpoint = var.vpc_defaults.provision_s3_vpc_endpoint ? { vpc_s3_endpoint = "true" } : {}
  public_s3_route_tables = flatten([
    for public_egress in local.any_public_egress : [
      for endpoint, endpoint_value in local.s3_endpoint : {
        public_egress = public_egress
        endpoint      = endpoint
      }
    ]
  ])
  private_s3_route_tables = flatten([
    for private_egress in local.private_egress_subnets : [
      for endpoint, endpoint_value in local.s3_endpoint : {
        private_egress = private_egress
        endpoint       = endpoint
      }
    ]
  ])

}

resource "aws_vpc_endpoint" "s3" {
  for_each = local.s3_endpoint

  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"

  tags = merge(var.tags, {
    Name = "amt-${var.vpc_details.environment_affix}"
  })
}

resource "aws_vpc_endpoint_route_table_association" "default" {
  for_each = local.s3_endpoint

  route_table_id  = aws_default_route_table.default.id
  vpc_endpoint_id = aws_vpc_endpoint.s3[each.key].id
}

resource "aws_vpc_endpoint_route_table_association" "public" {
  for_each = {
    for value in local.public_s3_route_tables : value.public_egress => value.endpoint
  }

  route_table_id  = aws_route_table.egress_public[each.key].id
  vpc_endpoint_id = aws_vpc_endpoint.s3[each.value].id
}

resource "aws_vpc_endpoint_route_table_association" "private" {
  for_each = {
    for value in local.private_s3_route_tables : value.private_egress => value.endpoint
  }

  route_table_id  = aws_route_table.egress_private[each.key].id
  vpc_endpoint_id = aws_vpc_endpoint.s3[each.value].id
}

resource "aws_security_group_rule" "s3" {
  for_each = local.s3_endpoint

  security_group_id = aws_default_security_group.default.id
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = aws_vpc_endpoint.s3[each.value].prfix_list_id
}
