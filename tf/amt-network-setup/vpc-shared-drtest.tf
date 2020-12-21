#-----------------------------------------------
# Shared drtest additional controls
#-----------------------------------------------
# The drtest vpc has extra controls not present for the other VPC's.
# We might someday want to include these into the vpc module.
#
# The drtest vpc itself is defined in ./vpc-shared.tf, so that the auto.tfvars did not
# need to be split up. (It was a compromise.)
#-----------------------------------------------

# The VPC module typically grants the default security group a wide access
#   so that things 'just work'. However, for the drtest vpc, we specifically
#   want things to _not work_ by default, unless specifically allowed.
# This is to prevent restored services from contaminating their prod counterparts
#   while restored and online for dr testing.

locals {
  # Get the isolated subnet ID's from the vpc module's output
  shared_drtest_isolated_subnets = module.shared_drtest_vpc.isolated_subnet_ids
  shared_drtest_isolated_subnet_ids = toset(values(local.shared_drtest_isolated_subnets))
  shared_drtest_vpc_id = module.shared_drtest_vpc.vpc_id
}

resource "aws_default_security_group" "shared_drtest_vpc_default_sg" {
  provider = aws.shared

  vpc_id = local.shared_drtest_vpc_id

  ingress {
    description = "Self-ingress."
    self        = true
    protocol    = -1
    from_port   = 0
    to_port     = 0
  }

  egress {
    description = "Self-egress."
    self        = true
    protocol    = -1
    from_port   = 0
    to_port     = 0
  }

  tags = merge(module.shared_drtest_tags.tags, {
    Name = "amt-${var.shared_vpc_details.drtest.environment_affix}-vpc-default-security-group"
  })
}

resource "aws_security_group" "shared_drtest_vpc_restored_instances_sg" {
  provider = aws.shared
  vpc_id = local.shared_drtest_vpc_id
  name = "amt-${var.shared_vpc_details.drtest.environment_affix}-restored-instances"
  description = "amt-${var.shared_vpc_details.drtest.environment_affix}-restored-instances"

  ingress {
    description = "Self-ingress."
    self        = true
    protocol    = -1
    from_port   = 0
    to_port     = 0
  }

  egress {
    description = "Self-egress."
    self        = true
    protocol    = -1
    from_port   = 0
    to_port     = 0
  }

  tags = merge(
    module.shared_drtest_tags.tags,
    {
      Name = "amt-${var.shared_vpc_details.drtest.environment_affix}-restored-instances",
      cloudendure_access_enabled = "true",
      cloudendure_environment = "shared-drtest"
    }
  )
}

resource "aws_network_acl" "shared_drtest_isolated_subnet_acl" {
  provider   = aws.shared
  vpc_id     = local.shared_drtest_vpc_id
  subnet_ids = local.shared_drtest_isolated_subnet_ids

  ingress {
    rule_no    = 1
    protocol   = -1
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    rule_no    = 2
    protocol   = -1
    action     = "deny"
    ipv6_cidr_block = "::/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 3
    protocol   = -1
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 4
    protocol   = -1
    action     = "deny"
    ipv6_cidr_block = "::/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "amt-${var.shared_vpc_details.drtest.environment_affix}-isolated-subnet-acl"
  }
}

resource "aws_route_table" "shared_drtest_isolated_subnet_route_table" {
  provider = aws.shared
  vpc_id = local.shared_drtest_vpc_id

  tags = {
    Name = "amt-${var.shared_vpc_details.drtest.environment_affix}-isolated-subnet-route-table"
  }
}

resource "aws_route_table_association" "shared_drtest_isolated_subnet_route_table_association" {
  provider       = aws.shared
  for_each       = local.shared_drtest_isolated_subnets
  subnet_id      = lookup(local.shared_drtest_isolated_subnets, each.key)
  route_table_id = aws_route_table.shared_drtest_isolated_subnet_route_table.id
}
