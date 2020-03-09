#-----------------------------------
# VPC and Subnets
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

resource "aws_subnet" "web_subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[0]
  cidr_block        = var.subnet_ranges[0]
  tags = {
    Name        = var.subnet_names[0]
    Environment = "${var.env_name}"
  }
}

resource "aws_subnet" "AppSubnetA" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[1]
  cidr_block        = var.subnet_ranges[1]
  tags = {
    Name        = var.subnet_names[1]
    Environment = "${var.env_name}"
  }
}
resource "aws_subnet" "data_subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[2]
  cidr_block        = var.subnet_ranges[2]
  tags = {
    Name        = var.subnet_names[2]
    Environment = "${var.env_name}"
  }
}
resource "aws_subnet" "OmniSubnetA" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[3]
  cidr_block        = var.subnet_ranges[3]
  tags = {
    Name        = var.subnet_names[3]
    Environment = "${var.env_name}"
  }
}
resource "aws_subnet" "OmniSubnetB" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[4]
  cidr_block        = var.subnet_ranges[4]
  tags = {
    Name        = var.subnet_names[4]
    Environment = "${var.env_name}"
  }
}
resource "aws_subnet" "web_subnet_b" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[5]
  cidr_block        = var.subnet_ranges[5]
  tags = {
    Name        = var.subnet_names[5]
    Environment = "${var.env_name}"
  }
}
resource "aws_subnet" "AppSubnetB" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[6]
  cidr_block        = var.subnet_ranges[6]
  tags = {
    Name        = var.subnet_names[6]
    Environment = "${var.env_name}"
  }
}
resource "aws_subnet" "data_subnet_b" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[7]
  cidr_block        = var.subnet_ranges[7]
  tags = {
    Name        = var.subnet_names[7]
    Environment = "${var.env_name}"
  }
}

#-----------------------------------
# Route Tables and Associations
#-----------------------------------
resource "aws_default_route_table" "dev_rt" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = var.transit_gateway_id
  }
  route {
    cidr_block         = "10.0.0.0/8"
    transit_gateway_id = var.transit_gateway_id
  }
  route {
    cidr_block         = "172.16.0.0/12"
    transit_gateway_id = var.transit_gateway_id
  }
  route {
    cidr_block         = "192.168.0.0/16"
    transit_gateway_id = var.transit_gateway_id
  }
  tags = {
    Name = "${var.env_name}RT"
  }
}

#-----------------------------------
# Security Group
#-----------------------------------
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
  ingress {
    protocol    = -1
    self        = true
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["10.98.0.0/21", "10.98.8.0/21"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.env_name}VpcSecurityGroup"
  }
}


#-----------------------------------
# Subnet Shares
#-----------------------------------
resource "aws_ram_resource_share" "dev_omni_subnets_share" {
  allow_external_principals = false
  name                      = "DevOmniSubnetShare"
  tags = {
    Name = "DevOmniSubnetShare"
  }
}
resource "aws_ram_principal_association" "dev_omnius_association" {
  principal          = "421354678477"
  resource_share_arn = aws_ram_resource_share.dev_omni_subnets_share.id
}
resource "aws_ram_resource_association" "dev_omni_subnet_a_association" {
  resource_arn       = aws_subnet.OmniSubnetA.arn
  resource_share_arn = aws_ram_resource_share.dev_omni_subnets_share.id
}
resource "aws_ram_resource_association" "dev_omni_subnet_b_association" {
  resource_arn       = aws_subnet.OmniSubnetB.arn
  resource_share_arn = aws_ram_resource_share.dev_omni_subnets_share.id
}

#-----------------------------------
# Outputs
#-----------------------------------
output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "subnet_ids" {
  value = [
    aws_subnet.web_subnet_a.id,
    aws_subnet.AppSubnetA.id,
    aws_subnet.data_subnet_a.id,
    aws_subnet.OmniSubnetA.id,
    aws_subnet.OmniSubnetB.id,
    aws_subnet.web_subnet_b.id,
    aws_subnet.AppSubnetB.id,
    aws_subnet.data_subnet_b.id
  ]
}
