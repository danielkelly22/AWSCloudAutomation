provider "aws" {}

provider "aws" {
  alias = "shared"
}

data "aws_region" "current" {}

resource "aws_vpc" "vpc" {
  cidr_block                       = var.vpc_details.cidr_block
  instance_tenancy                 = var.vpc_defaults.instance_tenancy
  enable_dns_hostnames             = var.vpc_defaults.enable_dns_hostnames
  enable_dns_support               = var.vpc_defaults.enable_dns_support
  enable_classiclink               = var.vpc_defaults.enable_classiclink
  enable_classiclink_dns_support   = var.vpc_defaults.enable_classiclink_dns_support
  assign_generated_ipv6_cidr_block = var.vpc_defaults.assign_generated_ipv6_cidr_block

  tags = merge(
    var.vpc_details.extra_tags,
    merge(
      var.tags,
      {
        Name        = "amt-${var.vpc_details.environment_affix}-vpc"
        environment = var.vpc_details.environment_affix
      }
    )
  )
}

resource "aws_subnet" "subnets" {
  for_each = var.vpc_details.subnets

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.value.availability_zone
  cidr_block        = cidrsubnet(
    var.vpc_details.cidr_block,
    each.value.cidr.newbits,
    each.value.cidr.netnum
  )

  tags = merge(
    each.value.extra_tags,
    merge(
      var.tags, {
        Name        = each.key
        environment = var.vpc_details.environment_affix
      }
    )
  )
}
