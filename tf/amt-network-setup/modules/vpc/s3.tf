locals {
  s3_endpoint = toset(
    var.vpc_defaults.provision_s3_vpc_endpoint ? ["vpc_s3_endpoint"] : []
  )
  public_route_table_ids = [
    for item in local.any_public_egress :
    aws_route_table.egress_public[item].id
  ]
  private_route_table_ids = [
    for item in local.private_egress_subnets :
    aws_route_table.egress_private[item].id
  ]
  route_table_ids = concat(
    [aws_default_route_table.default.id],
    local.public_route_table_ids, local.private_route_table_ids
  )
}

resource "aws_vpc_endpoint" "s3" {
  for_each = local.s3_endpoint

  vpc_endpoint_type  = "Gateway"
  vpc_id             = aws_vpc.vpc.id
  service_name       = "com.amazonaws.${data.aws_region.current.name}.s3"
  auto_accept        = true
  security_group_ids = [aws_default_security_group.default.id]
  route_table_ids    = local.route_table_ids

  tags = merge(var.tags, {
    Name = "amt-${var.vpc_details.environment_affix}"
  })
}
