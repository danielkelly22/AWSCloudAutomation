locals {
  s3_endpoint = var.vpc_defaults.provision_s3_vpc_endpoint ? { vpc_s3_endpoint = "true" } : {}
}

resource "aws_vpc_endpoint" "s3" {
  for_each = local.s3_endpoint

  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
}

resource "aws_vpc_endpoint_route_table_association" "default" {
  for_each = local.s3_endpoint

  route_table_id  = aws_default_route_table.default.id
  vpc_endpoint_id = aws_vpc_endpoint.s3[each.key].id
}
