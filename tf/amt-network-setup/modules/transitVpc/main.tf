#-----------------------------------
# VPC
#-----------------------------------
resource "aws_vpc" "vpc" {
  cidr_block                       = var.vpc_cidr
  instance_tenancy                 = "default"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  enable_classiclink               = false
  enable_classiclink_dns_support   = false
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name        = "${var.env_name}-VPC"
    Environment = "${var.env_name}"
  }
}

#-----------------------------------
# Subnets
#-----------------------------------
resource "aws_subnet" "TransitPublicPeeringSubnetA" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[0]
  cidr_block        = var.subnet_ranges[0]
  tags = {
    Name        = var.subnet_names[0]
    Environment = "${var.env_name}"
  }
}
resource "aws_subnet" "TransitPrivatePeeringSubnetA" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[1]
  cidr_block        = var.subnet_ranges[1]
  tags = {
    Name        = var.subnet_names[1]
    Environment = "${var.env_name}"
  }
}
resource "aws_subnet" "TransitMgmtSubnetA" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[2]
  cidr_block        = var.subnet_ranges[2]
  tags = {
    Name        = var.subnet_names[2]
    Environment = "${var.env_name}"
  }
}

#-----------------------------------
# Gateways
#-----------------------------------
resource "aws_eip" "nat_gw_ip" {
  vpc = true
  tags = {
    Name = "NatGatewayIp"
  }
}
resource "aws_nat_gateway" "gw_az_a" {
  allocation_id = aws_eip.nat_gw_ip.id
  subnet_id     = aws_subnet.TransitPublicPeeringSubnetA.id
  tags = {
    Name = "TransitVpcNatGateway"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "TransitVpcInternetGateway"
  }
}

#-----------------------------------
# Route Tables and Associations
#-----------------------------------
resource "aws_route_table" "egress_public_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  route {
    cidr_block         = "10.0.0.0/8"
    transit_gateway_id = var.transit_gateway_id
  }
  tags = {
    Name = "${var.env_name}EgressPublicRT"
  }
}
resource "aws_route_table_association" "egress_public_rt_association" {
  subnet_id      = aws_subnet.TransitPublicPeeringSubnetA.id
  route_table_id = aws_route_table.egress_public_rt.id
}


resource "aws_route_table" "egress_private_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw_az_a.id
  }
  tags = {
    Name = "${var.env_name}EgressPrivateRT"
  }
}
resource "aws_route_table_association" "egress_private_rt_association" {
  subnet_id      = aws_subnet.TransitPrivatePeeringSubnetA.id
  route_table_id = aws_route_table.egress_private_rt.id
}

#-----------------------------------
# Outputs
#-----------------------------------
output "internet_gateway_id" {
  value = aws_internet_gateway.internet_gateway.id
}
output "nat_gateway_id" {
  value = aws_nat_gateway.gw_az_a.id
}
output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "subnet_ids" {
  value = [aws_subnet.TransitPublicPeeringSubnetA.id, aws_subnet.TransitPrivatePeeringSubnetA.id]
}
