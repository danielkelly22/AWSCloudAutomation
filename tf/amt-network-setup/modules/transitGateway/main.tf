#-----------------------------------------------
# Set up proviers 
#-----------------------------------------------
provider "aws" {
  alias = "sandbox"
}
provider "aws" {
  alias = "dev"
}
provider "aws" {
  alias = "uat"
}
provider "aws" {
  alias = "shared"
}
provider "aws" {
  alias = "prod"
}

#-----------------------------------------------
# Set up data sources 
#-----------------------------------------------
# data "aws_ec2_transit_gateway_vpn_attachment" "attachment" {
#   transit_gateway_id = aws_ec2_transit_gateway.TransitGateway.id
#   vpn_connection_id  = var.vpn_connection_id
# }
data "aws_organizations_organization" "organization" {}

#-----------------------------------------------
# Set up Transit Gateway
#-----------------------------------------------
resource "aws_ec2_transit_gateway" "TransitGateway" {
  provider                        = aws.shared
  description                     = "${var.env_name} Transit Gateway"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    Name        = "${var.env_name}Gateway"
    Environment = "${var.env_name}"
  }
}


#-----------------------------------------------
# Set up Transit Gateway Share
#-----------------------------------------------
resource "aws_ram_resource_share" "transit_gateway_share" {
  provider                  = aws.shared
  allow_external_principals = false
  name                      = "SharedTransitGateway"
  tags = {
    Name = "Transit Garteway Share"
  }
}
resource "aws_ram_principal_association" "organization_principal" {
  provider           = aws.shared
  principal          = data.aws_organizations_organization.organization.arn
  resource_share_arn = aws_ram_resource_share.transit_gateway_share.id
}
resource "aws_ram_resource_association" "transit_gateway_association" {
  provider           = aws.shared
  resource_arn       = aws_ec2_transit_gateway.TransitGateway.arn
  resource_share_arn = aws_ram_resource_share.transit_gateway_share.id
}


#-----------------------------------------------
# Set up Transit Gateway Attachments
#-----------------------------------------------
## prod vpc attachment and acceptor ##
resource "aws_ec2_transit_gateway_vpc_attachment" "prod_attachment" {
  provider                                        = aws.prod
  subnet_ids                                      = var.prod_subnet_ids
  transit_gateway_id                              = aws_ec2_transit_gateway.TransitGateway.id
  vpc_id                                          = var.vpc_ids[0]
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  # edit lifecycle of the default arguments above to supress odd behavior
  lifecycle {
    ignore_changes = [transit_gateway_default_route_table_association, transit_gateway_default_route_table_propagation]
  }
  tags = {
    Name = "ProdVpcGatewayAttachment"
    Side = "Requestor"
  }
  depends_on = [aws_ram_principal_association.organization_principal, aws_ram_resource_association.transit_gateway_association]
}
resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "prod_accepter" {
  provider                                        = aws.shared
  transit_gateway_attachment_id                   = aws_ec2_transit_gateway_vpc_attachment.prod_attachment.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "ProdVpcGatewayAttachment"
    Side = "Accepter"
  }
}

# uat vpc attachment and acceptor
resource "aws_ec2_transit_gateway_vpc_attachment" "uat_attachment" {
  provider                                        = aws.uat
  subnet_ids                                      = var.uat_subnet_ids
  transit_gateway_id                              = aws_ec2_transit_gateway.TransitGateway.id
  vpc_id                                          = var.vpc_ids[1]
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  # edit lifecycle of the default arguments above to supress odd behavior
  lifecycle {
    ignore_changes = [transit_gateway_default_route_table_association, transit_gateway_default_route_table_propagation]
  }
  tags = {
    Name = "UatVpcGatewayAttachment"
    Side = "Requestor"
  }
  depends_on = [aws_ram_principal_association.organization_principal, aws_ram_resource_association.transit_gateway_association]
}
resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "uat_accepter" {
  provider                                        = aws.shared
  transit_gateway_attachment_id                   = aws_ec2_transit_gateway_vpc_attachment.uat_attachment.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "UatVpcGatewayAttachment"
    Side = "Accepter"
  }
}

## dev vpc attachment and acceptor
resource "aws_ec2_transit_gateway_vpc_attachment" "dev_attachment" {
  provider                                        = aws.dev
  subnet_ids                                      = var.dev_subnet_ids
  transit_gateway_id                              = aws_ec2_transit_gateway.TransitGateway.id
  vpc_id                                          = var.vpc_ids[2]
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  # edit lifecycle of the default arguments above to supress odd behavior
  lifecycle {
    ignore_changes = [transit_gateway_default_route_table_association, transit_gateway_default_route_table_propagation]
  }
  tags = {
    Name = "DevVpcGatewayAttachment"
    Side = "Requestor"
  }
  depends_on = [aws_ram_principal_association.organization_principal, aws_ram_resource_association.transit_gateway_association]
}
resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "dev_accepter" {
  provider                                        = aws.shared
  transit_gateway_attachment_id                   = aws_ec2_transit_gateway_vpc_attachment.dev_attachment.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "DevVpcGatewayAttachment"
    Side = "Accepter"
  }
}

# transit vpc attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "transit_attachment" {
  provider                                        = aws.shared
  subnet_ids                                      = var.transit_subnet_ids
  transit_gateway_id                              = aws_ec2_transit_gateway.TransitGateway.id
  vpc_id                                          = var.vpc_ids[3]
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "TransitVpcGatewayAttachment"
    Side = "Requestor"
  }
  depends_on = [aws_ram_principal_association.organization_principal, aws_ram_resource_association.transit_gateway_association]
}


# shared vpc attachment 
resource "aws_ec2_transit_gateway_vpc_attachment" "shared_attachment" {
  provider                                        = aws.shared
  subnet_ids                                      = var.shared_subnet_ids
  transit_gateway_id                              = aws_ec2_transit_gateway.TransitGateway.id
  vpc_id                                          = var.vpc_ids[4]
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "SharedVpcGatewayAttachment"
    Side = "Requestor"
  }
  depends_on = [aws_ram_principal_association.organization_principal, aws_ram_resource_association.transit_gateway_association]
}

#-----------------------------------------------
# Route Tables
#-----------------------------------------------
# VPN Routes
resource "aws_ec2_transit_gateway_route_table" "tg_vpn_rt" {
  provider           = aws.shared
  transit_gateway_id = aws_ec2_transit_gateway.TransitGateway.id
  tags = {
    Name = "${var.env_name}GwVpnRouteTable"
  }
}
resource "aws_ec2_transit_gateway_route_table_association" "tg_vpn_rt_association" {
  provider                       = aws.shared
  transit_gateway_attachment_id  = "tgw-attach-08d05fba70965a915"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_vpn_rt.id
}
# resource "aws_ec2_transit_gateway_route" "tg_10_route" {
#   provider                       = aws.shared
#   destination_cidr_block         = "10.0.0.0/8"
#   transit_gateway_attachment_id  = "tgw-attach-08d05fba70965a915"
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_vpn_rt.id
# }
# resource "aws_ec2_transit_gateway_route" "tg_172_route" {
#   provider                       = aws.shared
#   destination_cidr_block         = "172.16.0.0/12"
#   transit_gateway_attachment_id  = "tgw-attach-08d05fba70965a915"
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_vpn_rt.id
# }
# resource "aws_ec2_transit_gateway_route" "tg_192_route" {
#   provider                       = aws.shared
#   destination_cidr_block         = "192.168.0.0/16"
#   transit_gateway_attachment_id  = "tgw-attach-08d05fba70965a915"
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_vpn_rt.id
# }
resource "aws_ec2_transit_gateway_route" "tg_vpn_shared_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.shared_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_vpn_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_vpn_dev_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.dev_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_vpn_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_vpn_uat_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.uat_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.uat_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_vpn_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_vpn_prod_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.prod_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prod_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_vpn_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_vpn_transit_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.transit_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_vpn_rt.id
}


# Transit VPC routes
resource "aws_ec2_transit_gateway_route_table" "tg_egress_rt" {
  provider           = aws.shared
  transit_gateway_id = aws_ec2_transit_gateway.TransitGateway.id
  tags = {
    Name = "${var.env_name}GwTransitVpcRT"
  }
}
resource "aws_ec2_transit_gateway_route_table_association" "tg_egress_rt_association" {
  provider                       = aws.shared
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_egress_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_dev_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.dev_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_egress_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_uat_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.uat_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.uat_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_egress_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_prod_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.prod_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prod_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_egress_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_shared_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.shared_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_egress_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_transit_private1_route" {
  provider                       = aws.shared
  destination_cidr_block         = "10.0.0.0/8"
  transit_gateway_attachment_id  = "tgw-attach-08d05fba70965a915"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_egress_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_tranist_private2_route" {
  provider                       = aws.shared
  destination_cidr_block         = "172.16.0.0/12"
  transit_gateway_attachment_id  = "tgw-attach-08d05fba70965a915"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_egress_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_transit_private3_route" {
  provider                       = aws.shared
  destination_cidr_block         = "192.168.0.0/16"
  transit_gateway_attachment_id  = "tgw-attach-08d05fba70965a915"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_egress_rt.id
}

## Shared RT
resource "aws_ec2_transit_gateway_route_table" "tg_application_rt" {
  provider           = aws.shared
  transit_gateway_id = aws_ec2_transit_gateway.TransitGateway.id
  tags = {
    Name = "${var.env_name}GwSharedVpcRT"
  }
}
resource "aws_ec2_transit_gateway_route_table_association" "tg_application_rt_shared_association" {
  provider                       = aws.shared
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_application_rt.id
  depends_on                     = [aws_ec2_transit_gateway_vpc_attachment.shared_attachment]
}

resource "aws_ec2_transit_gateway_route" "tg_application_route" {
  provider                       = aws.shared
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_application_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_shared_transit_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.transit_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_application_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_shared_dev_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.dev_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_application_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_shared_uat_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.uat_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.uat_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_application_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_shared_prod_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.prod_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prod_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_application_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_shared_10_route" {
  provider                       = aws.shared
  destination_cidr_block         = "10.0.0.0/8"
  transit_gateway_attachment_id  = "tgw-attach-08d05fba70965a915"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_application_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_shared_172_route" {
  provider                       = aws.shared
  destination_cidr_block         = "172.16.0.0/12"
  transit_gateway_attachment_id  = "tgw-attach-08d05fba70965a915"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_application_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_shared_192_route" {
  provider                       = aws.shared
  destination_cidr_block         = "192.168.0.0/16"
  transit_gateway_attachment_id  = "tgw-attach-08d05fba70965a915"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_application_rt.id
}

# Dev RT
resource "aws_ec2_transit_gateway_route_table" "tg_dev_rt" {
  provider           = aws.shared
  transit_gateway_id = aws_ec2_transit_gateway.TransitGateway.id
  tags = {
    Name = "${var.env_name}GwDevVpcRT"
  }
}
resource "aws_ec2_transit_gateway_route_table_association" "tg_dev_association" {
  provider                       = aws.shared
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_dev_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_dev_internet_route" {
  provider                       = aws.shared
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_dev_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_dev_shared_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.shared_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_dev_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_dev_transit_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.transit_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_dev_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_dev_private1_route" {
  provider                       = aws.shared
  destination_cidr_block         = "10.0.0.0/8"
  transit_gateway_attachment_id  = "tgw-attach-08d05fba70965a915"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_dev_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_dev_private2_route" {
  provider                       = aws.shared
  destination_cidr_block         = "172.16.0.0/12"
  transit_gateway_attachment_id  = "tgw-attach-08d05fba70965a915"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_dev_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_dev_private3_route" {
  provider                       = aws.shared
  destination_cidr_block         = "192.168.0.0/16"
  transit_gateway_attachment_id  = "tgw-attach-08d05fba70965a915"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_dev_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_dev_uatblackhole_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.uat_cidr
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_dev_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_dev_prodblackhole_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.prod_cidr
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_dev_rt.id
}

# Uat RT
resource "aws_ec2_transit_gateway_route_table" "tg_uat_rt" {
  provider           = aws.shared
  transit_gateway_id = aws_ec2_transit_gateway.TransitGateway.id
  tags = {
    Name = "${var.env_name}GwUatVpcRT"
  }
}
resource "aws_ec2_transit_gateway_route_table_association" "tg_uat_association" {
  provider                       = aws.shared
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.uat_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_uat_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_uat_internet_route" {
  provider                       = aws.shared
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_uat_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_uat_shared_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.shared_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_uat_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_uat_transit_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.transit_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_uat_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_uat_private1_route" {
  provider                       = aws.shared
  destination_cidr_block         = "10.0.0.0/8"
  transit_gateway_attachment_id  = "tgw-attach-08d05fba70965a915"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_uat_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_uat_private2_route" {
  provider                       = aws.shared
  destination_cidr_block         = "172.16.0.0/12"
  transit_gateway_attachment_id  = "tgw-attach-08d05fba70965a915"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_uat_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_uat_private3_route" {
  provider                       = aws.shared
  destination_cidr_block         = "192.168.0.0/16"
  transit_gateway_attachment_id  = "tgw-attach-08d05fba70965a915"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_uat_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_uat_devblackhole_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.dev_cidr
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_uat_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_uat_prodblackhole_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.prod_cidr
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_uat_rt.id
}

# Prod RT
resource "aws_ec2_transit_gateway_route_table" "tg_prod_rt" {
  provider           = aws.shared
  transit_gateway_id = aws_ec2_transit_gateway.TransitGateway.id
  tags = {
    Name = "${var.env_name}GwProdVpcRT"
  }
}
resource "aws_ec2_transit_gateway_route_table_association" "tg_prod_association" {
  provider                       = aws.shared
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prod_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_prod_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_prod_internet_route" {
  provider                       = aws.shared
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_prod_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_prod_shared_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.shared_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_prod_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_prod_transit_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.transit_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_prod_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_prod_private1_route" {
  provider                       = aws.shared
  destination_cidr_block         = "10.0.0.0/8"
  transit_gateway_attachment_id  = "tgw-attach-08d05fba70965a915"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_prod_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_prod_private2_route" {
  provider                       = aws.shared
  destination_cidr_block         = "172.16.0.0/12"
  transit_gateway_attachment_id  = "tgw-attach-08d05fba70965a915"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_prod_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_prod_private3_route" {
  provider                       = aws.shared
  destination_cidr_block         = "192.168.0.0/16"
  transit_gateway_attachment_id  = "tgw-attach-08d05fba70965a915"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_prod_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_prod_devblackhole_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.dev_cidr
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_prod_rt.id
}
resource "aws_ec2_transit_gateway_route" "tg_prod_uatblackhole_route" {
  provider                       = aws.shared
  destination_cidr_block         = var.uat_cidr
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tg_prod_rt.id
}

#-----------------------------------------------
# Outputs
#-----------------------------------------------
output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.TransitGateway.id
}
