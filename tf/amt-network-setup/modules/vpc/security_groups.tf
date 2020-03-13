# overriding default security group, because it allows all ingress traffic
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "Allow all IP addresses within this VPC to access other IP address in the same VPC."
    self        = true
    protocol    = -1
    from_port   = 0
    to_port     = 0
  }

  dynamic "ingress" {
    for_each = var.aws_routable_cidr_blocks

    content {
      description = "Allows inbound traffic from ${ingress.key}"
      cidr_blocks = [ingress.value]
      protocol    = -1
      from_port   = 0
      to_port     = 0
    }
  }

  dynamic "egress" {
    for_each = var.internet_routable_cidr_blocks

    content {
      description = "Allows all outbound internet traffic to ${egress.key}"
      cidr_blocks = [egress.value]
      protocol    = -1
      from_port   = 0
      to_port     = 0
    }
  }

  dynamic "egress" {
    for_each = var.private_egress_blocks

    content {
      description = "Allows outbound local traffic to ${egress.key}"
      cidr_blocks = [egress.value]
      protocol    = -1
      from_port   = 0
      to_port     = 0
    }
  }

  tags = merge(var.tags, {
    Name = "amt-${var.vpc_details.environment_affix}-vpc-default-security-group"
  })
}
