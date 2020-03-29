locals {
  # The list is empty if no S3 VPC endpoint is to be created
  s3_endpoint = toset(var.vpc_defaults.provision_s3_vpc_endpoint ? ["vpc_s3_endpoint"] : [])

  # Creates a flattened list of public route tables
  public_s3_route_tables = flatten([
    for public_egress in local.any_public_egress : [
      for endpoint, endpoint_value in local.s3_endpoint : {
        public_egress = public_egress
        endpoint      = endpoint
      }
    ]
  ])

  # Creates a flattened list of private route tables
  private_s3_route_tables = flatten([
    for private_egress in local.private_egress_subnets : [
      for endpoint, endpoint_value in local.s3_endpoint : {
        private_egress = private_egress
        endpoint       = endpoint
      }
    ]
  ])
}

# Creates a VPC endpoint for S3. This allows private routing to S3 (does 
# not require an internet gateway)
resource "aws_vpc_endpoint" "s3" {
  for_each = local.s3_endpoint

  vpc_endpoint_type = "Gateway"
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  auto_accept       = true

  tags = merge(var.tags, {
    Name = "amt-${var.vpc_details.environment_affix}"
  })
}

# Associates the VPC endpoint to the default route table.
resource "aws_vpc_endpoint_route_table_association" "default" {
  for_each = local.s3_endpoint

  route_table_id  = aws_default_route_table.default.id
  vpc_endpoint_id = aws_vpc_endpoint.s3[each.key].id
}

# Associates the VPC endpoint to the public route table
resource "aws_vpc_endpoint_route_table_association" "public" {
  for_each = {
    for value in local.public_s3_route_tables : value.public_egress => value.endpoint
  }

  route_table_id  = aws_route_table.egress_public[each.key].id
  vpc_endpoint_id = aws_vpc_endpoint.s3[each.value].id
}

# Associates the VPC endpoint to all of the private gateways
resource "aws_vpc_endpoint_route_table_association" "private" {
  for_each = {
    for value in local.private_s3_route_tables : value.private_egress => value.endpoint
  }

  route_table_id  = aws_route_table.egress_private[each.key].id
  vpc_endpoint_id = aws_vpc_endpoint.s3[each.value].id
}
