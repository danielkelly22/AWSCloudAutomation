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

resource "aws_subnet" "CoreSubnetA" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[0]
  cidr_block        = var.subnet_ranges[0]
  tags = {
    Name        = var.subnet_names[0]
    Environment = "${var.env_name}"
  }
}

resource "aws_subnet" "CoreSubnetB" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[1]
  cidr_block        = var.subnet_ranges[1]
  tags = {
    Name        = var.subnet_names[1]
    Environment = "${var.env_name}"
  }
}
resource "aws_subnet" "JumpSubnetA" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[2]
  cidr_block        = var.subnet_ranges[2]
  tags = {
    Name        = var.subnet_names[2]
    Environment = "${var.env_name}"
  }
}
resource "aws_subnet" "JumpSubnetB" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[3]
  cidr_block        = var.subnet_ranges[3]
  tags = {
    Name        = var.subnet_names[3]
    Environment = "${var.env_name}"
  }
}
resource "aws_subnet" "TrainerSubnetA" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[4]
  cidr_block        = var.subnet_ranges[4]
  tags = {
    Name        = var.subnet_names[4]
    Environment = "${var.env_name}"
  }
}
resource "aws_subnet" "TrainerSubnetB" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[5]
  cidr_block        = var.subnet_ranges[5]
  tags = {
    Name        = var.subnet_names[5]
    Environment = "${var.env_name}"
  }
}
#-----------------------------------
# Route Tables and Associations
#-----------------------------------
resource "aws_default_route_table" "rt" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-0d900c3c9f361f88d"
    #transit_gateway_id = var.transit_gateway_id
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
# Subnet Shares
#-----------------------------------
resource "aws_ram_resource_share" "trainer_subnets_share" {
  allow_external_principals = false
  name                      = "TrainerSubnetShare"
  tags = {
    Name = "TrainerSubnetShare"
  }
}
resource "aws_ram_principal_association" "shared_trainer_association" {
  principal          = "421354678477"
  resource_share_arn = aws_ram_resource_share.trainer_subnets_share.id
}
resource "aws_ram_resource_association" "trainer_subnet_a_association" {
  resource_arn       = aws_subnet.TrainerSubnetA.arn
  resource_share_arn = aws_ram_resource_share.trainer_subnets_share.id
}
resource "aws_ram_resource_association" "trainer_subnet_b_association" {
  resource_arn       = aws_subnet.TrainerSubnetB.arn
  resource_share_arn = aws_ram_resource_share.trainer_subnets_share.id
}

#-----------------------------------
# Outputs
#-----------------------------------
output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "subnet_ids" {
  value = [aws_subnet.CoreSubnetA.id, aws_subnet.CoreSubnetB.id, aws_subnet.JumpSubnetA.id, aws_subnet.JumpSubnetB.id, aws_subnet.TrainerSubnetA.id, aws_subnet.TrainerSubnetB.id]
}
