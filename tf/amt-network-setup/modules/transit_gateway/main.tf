data "aws_region" "current" {}

data "aws_organizations_organization" "organization" {}

resource "aws_ec2_transit_gateway" "tgw" {
  description = var.description == "" ? "Transit Gateway for the ${data.aws_region.current.name} region" : var.description
  #"Transit Transit Gateway"

  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = merge(var.tags, {
    Name = "amt-${data.aws_region.current.name}-tgw"
  })
}

resource "aws_ram_resource_share" "tgw_share" {
  allow_external_principals = false
  name                      = "amt-${data.aws_region.current.name}-tgw-share"
  tags = merge(var.tags, {
    Name = "amt-${data.aws_region.current.name}-tgw-share"
  })
}
resource "aws_ram_principal_association" "tgw_org_principal" {
  principal          = data.aws_organizations_organization.organization.arn
  resource_share_arn = aws_ram_resource_share.tgw_share.id
}
resource "aws_ram_resource_association" "transit_gateway_association" {
  resource_arn       = aws_ec2_transit_gateway.tgw.arn
  resource_share_arn = aws_ram_resource_share.tgw_share.id
}
