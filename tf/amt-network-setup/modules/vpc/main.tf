provider "aws" {}

provider "aws" {
  alias = "transit"
}

resource "aws_vpc" "vpc" {
  cidr_block                       = var.vpc_details.cidr_block
  instance_tenancy                 = var.vpc_defaults.instance_tenancy
  enable_dns_hostnames             = var.vpc_defaults.enable_dns_hostnames
  enable_dns_support               = var.vpc_defaults.enable_dns_support
  enable_classiclink               = var.vpc_defaults.enable_classiclink
  enable_classiclink_dns_support   = var.vpc_defaults.enable_classiclink_dns_support
  assign_generated_ipv6_cidr_block = var.vpc_defaults.assign_generated_ipv6_cidr_block

  tags = merge(var.tags, {
    Name        = "amt-${var.vpc_details.environment_affix}-vpc"
    environment = var.vpc_details.environment_affix
  })
}

resource "aws_subnet" "subnets" {
  for_each = var.vpc_details.subnets

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.value.availability_zone
  cidr_block        = cidrsubnet(var.vpc_details.cidr_block, each.value.cidr.newbits, each.value.cidr.netnum)
  tags = merge(var.tags, {
    Name        = each.key
    environment = var.vpc_details.environment_affix
  })
}

resource "aws_ram_resource_share" "subnets" {
  for_each = var.vpc_details.subnet_shares

  name                      = each.key
  allow_external_principals = each.value.allow_external_principals

  tags = merge(var.tags, {
    Name = "amt-${var.vpc_details.environment_affix}-ram-subnet-to-${each.value.target_name}"
  })
}

resource "aws_ram_principal_association" "subnet" {
  for_each = var.vpc_details.subnet_shares

  principal          = each.value.principal
  resource_share_arn = aws_ram_resource_share.subnets[each.key].arn
}

locals {
  subnet_shares_flat = flatten([
    for share_key, share in var.vpc_details.subnet_shares : [
      for subnet_key, subnet in share.subnets : {
        share_key  = share_key
        subnet_key = subnet_key
      }
    ]
  ])
}

resource "aws_ram_resource_association" "subnet_associations" {
  for_each = {
    for share in local.subnet_shares_flat : "${share.share_key}.${share.subnet_key}" => share
  }

  resource_arn       = aws_subnet.subnets[each.value.subnet_key].arn
  resource_share_arn = aws_ram_resource_share.subnets[each.value.share_key].arn
}

locals {
  transit_subnet_ids = [
    for subnet in var.vpc_details.transited_subnets :
    aws_subnet.subnets[subnet].id
  ]
}
