

locals {
  max_subnet_length = "${max(length(var.private_subnets))}"
  nat_gateway_count = "${var.single_nat_gateway ? 1 : (var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length)}"

  # Use `local.vpc_id` to give a hint to Terraform that subnets should be deleted before secondary CIDR blocks can be free!
  vpc_id = "${element(concat(aws_vpc_ipv4_cidr_block_association.this.*.vpc_id, aws_vpc.this.*.id, list("")), 0)}"
}

######
# VPC
######
resource "aws_vpc" "this" {
  cidr_block                       = "${var.cidr}"
  instance_tenancy                 = "${var.instance_tenancy}"
  enable_dns_hostnames             = "${var.enable_dns_hostnames}"
  enable_dns_support               = "${var.enable_dns_support}"
  assign_generated_ipv6_cidr_block = "${var.assign_generated_ipv6_cidr_block}"

  tags = "${merge(map("Name", format("%s", var.name)), var.tags, var.vpc_tags)}"
}
resource "aws_default_route_table" "r" {
  default_route_table_id = "${aws_vpc.this.default_route_table_id}"


  tags = "${merge(map("Name", format("%s-private-route", var.name)), var.tags)}"
}
resource "aws_default_security_group" "default" {
  vpc_id = "${aws_vpc.this.id}"
    tags = "${merge(map("Name", format("%s-sg", var.name)), var.tags)}"
    ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
    from_port   = 22
    to_port     = 22  
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }
  ingress {
    from_port   = 3389
    to_port     = 3389 
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group_rule" "allow_all" {
  type            = "ingress"
  from_port       = 0
  to_port         = 65535
  protocol        = "-1"
  self= true

  security_group_id = "${aws_default_security_group.default.id}" 
}
resource "aws_ssm_parameter" "vpc_id" {
  name = "${var.name}-vpc"

  value = "${aws_vpc.this.id}"

  description= "${format("Vpc ID for %s %s",var.name,"vpc")}"

  tags = "${merge(map("Name", format("%s-Vpc", var.name)), var.tags)}"

  overwrite= true

  type="String"
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count = "${length(var.secondary_cidr_blocks) > 0 ? length(var.secondary_cidr_blocks) : 0}"

  vpc_id = "${aws_vpc.this.id}"

  cidr_block = "${element(var.secondary_cidr_blocks, count.index)}"
}

###################
# Internet Gateway
###################
resource "aws_internet_gateway" "this" {
  count = "${var.enable_internet_gateway ? 1 : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(map("Name", format("%s", var.name)), var.tags, var.igw_tags)}"
}

################
# Publiс routes
################
resource "aws_route_table" "public" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(map("Name", format("%s-${var.public_subnet_suffix}", var.name)), var.tags, var.public_route_table_tags)}"
}

resource "aws_route" "public_internet_gateway" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"

  timeouts {
    create = "5m"
  }
}

#################
# Private routes
# There are as many routing tables as the number of NAT gateways
#################
resource "aws_route_table" "private" {
  count = "${length(var.private_subnets) > 0 ? 0 : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(map("Name", (var.single_nat_gateway ? "${var.name}-${var.private_subnet_suffix}" : format("%s-${var.private_subnet_suffix}-%s", var.name, element(var.azs, count.index)))), var.tags, var.private_route_table_tags)}"

  lifecycle {
    # When attaching VPN gateways it is common to define aws_vpn_gateway_route_propagation
    # resources that manipulate the attributes of the routing table (typically for the private subnets)
    ignore_changes = ["propagating_vgws"]
  }
}

################
# Public subnet
################
resource "aws_subnet" "public" {
  count = "${length(var.public_subnets) > 0 && (!var.one_nat_gateway_per_az || length(var.public_subnets) >= length(var.azs)) ? length(var.public_subnets) : 0}"

  vpc_id                  = "${local.vpc_id}"
  cidr_block              = "${element(concat(var.public_subnets, list("")), count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags = "${merge(map("Name", format("%s-%s",var.name,element(var.public_subnets_names, count.index))), var.tags, var.private_subnet_tags)}"
}

#################
# Private subnet
#################
resource "aws_subnet" "private" {
  count = "${length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"

  vpc_id            = "${local.vpc_id}"
  cidr_block        = "${var.private_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(map("Name", format("%s-%s",var.name,element(var.private_subnets_names, count.index))), var.tags, var.private_subnet_tags)}"
}



#######################
# Default Network ACLs
#######################
resource "aws_default_network_acl" "this" {
  count = "${var.manage_default_network_acl ? 1 : 0}"

  default_network_acl_id = "${element(concat(aws_vpc.this.*.default_network_acl_id, list("")), 0)}"

  ingress = "${var.default_network_acl_ingress}"
  egress  = "${var.default_network_acl_egress}"

  tags = "${merge(map("Name", format("%s", var.default_network_acl_name)), var.tags, var.default_network_acl_tags)}"

  lifecycle {
    ignore_changes = ["subnet_ids"]
  }
}

########################
# Public Network ACLs
########################
resource "aws_network_acl" "public" {
  count = "${var.public_dedicated_network_acl && length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id     = "${element(concat(aws_vpc.this.*.id, list("")), 0)}"
  subnet_ids = ["${aws_subnet.public.*.id}"]

  tags = "${merge(map("Name", format("%s-${var.public_subnet_suffix}", var.name)), var.tags, var.public_acl_tags)}"
}

resource "aws_network_acl_rule" "public_inbound" {
  count = "${var.public_dedicated_network_acl && length(var.public_subnets) > 0 ? length(var.public_inbound_acl_rules) : 0}"

  network_acl_id = "${aws_network_acl.public.id}"

  egress      = false
  rule_number = "${lookup(var.public_inbound_acl_rules[count.index], "rule_number")}"
  rule_action = "${lookup(var.public_inbound_acl_rules[count.index], "rule_action")}"
  from_port   = "${lookup(var.public_inbound_acl_rules[count.index], "from_port")}"
  to_port     = "${lookup(var.public_inbound_acl_rules[count.index], "to_port")}"
  protocol    = "${lookup(var.public_inbound_acl_rules[count.index], "protocol")}"
  cidr_block  = "${lookup(var.public_inbound_acl_rules[count.index], "cidr_block")}"
}

resource "aws_network_acl_rule" "public_outbound" {
  count = "${var.public_dedicated_network_acl && length(var.public_subnets) > 0 ? length(var.public_outbound_acl_rules) : 0}"

  network_acl_id = "${aws_network_acl.public.id}"

  egress      = true
  rule_number = "${lookup(var.public_outbound_acl_rules[count.index], "rule_number")}"
  rule_action = "${lookup(var.public_outbound_acl_rules[count.index], "rule_action")}"
  from_port   = "${lookup(var.public_outbound_acl_rules[count.index], "from_port")}"
  to_port     = "${lookup(var.public_outbound_acl_rules[count.index], "to_port")}"
  protocol    = "${lookup(var.public_outbound_acl_rules[count.index], "protocol")}"
  cidr_block  = "${lookup(var.public_outbound_acl_rules[count.index], "cidr_block")}"
}

#######################
# Private Network ACLs
#######################
resource "aws_network_acl" "private" {
  count = "${var.private_dedicated_network_acl && length(var.private_subnets) > 0 ? 1 : 0}"

  vpc_id     = "${element(concat(aws_vpc.this.*.id, list("")), 0)}"
  subnet_ids = ["${aws_subnet.private.*.id}"]

  tags = "${merge(map("Name", format("%s-${var.private_subnet_suffix}", var.name)), var.tags, var.private_acl_tags)}"
}

resource "aws_network_acl_rule" "private_inbound" {
  count = "${var.private_dedicated_network_acl && length(var.private_subnets) > 0 ? length(var.private_inbound_acl_rules) : 0}"

  network_acl_id = "${aws_network_acl.private.id}"

  egress      = false
  rule_number = "${lookup(var.private_inbound_acl_rules[count.index], "rule_number")}"
  rule_action = "${lookup(var.private_inbound_acl_rules[count.index], "rule_action")}"
  from_port   = "${lookup(var.private_inbound_acl_rules[count.index], "from_port")}"
  to_port     = "${lookup(var.private_inbound_acl_rules[count.index], "to_port")}"
  protocol    = "${lookup(var.private_inbound_acl_rules[count.index], "protocol")}"
  cidr_block  = "${lookup(var.private_inbound_acl_rules[count.index], "cidr_block")}"
}

resource "aws_network_acl_rule" "private_outbound" {
  count = "${var.private_dedicated_network_acl && length(var.private_subnets) > 0 ? length(var.private_outbound_acl_rules) : 0}"

  network_acl_id = "${aws_network_acl.private.id}"

  egress      = true
  rule_number = "${lookup(var.private_outbound_acl_rules[count.index], "rule_number")}"
  rule_action = "${lookup(var.private_outbound_acl_rules[count.index], "rule_action")}"
  from_port   = "${lookup(var.private_outbound_acl_rules[count.index], "from_port")}"
  to_port     = "${lookup(var.private_outbound_acl_rules[count.index], "to_port")}"
  protocol    = "${lookup(var.private_outbound_acl_rules[count.index], "protocol")}"
  cidr_block  = "${lookup(var.private_outbound_acl_rules[count.index], "cidr_block")}"
}

##############
# NAT Gateway
##############
# Workaround for interpolation not being able to "short-circuit" the evaluation of the conditional branch that doesn't end up being used
# Source: https://github.com/hashicorp/terraform/issues/11566#issuecomment-289417805
#
# The logical expression would be
#
#    nat_gateway_ips = var.reuse_nat_ips ? var.external_nat_ip_ids : aws_eip.nat.*.id
#
# but then when count of aws_eip.nat.*.id is zero, this would throw a resource not found error on aws_eip.nat.*.id.
locals {
  nat_gateway_ips = "${split(",", (var.reuse_nat_ips ? join(",", var.external_nat_ip_ids) : join(",", aws_eip.nat.*.id)))}"
}

resource "aws_eip" "nat" {
  count = "${(var.enable_nat_gateway && !var.reuse_nat_ips) ? local.nat_gateway_count : 0}"

  vpc = true

  tags = "${merge(map("Name", format("%s-%s", var.name, element(var.azs, (var.single_nat_gateway ? 0 : count.index)))), var.tags, var.nat_eip_tags)}"
}

resource "aws_nat_gateway" "this" {
  count = "${var.enable_nat_gateway ? local.nat_gateway_count : 0}"

  allocation_id = "${element(local.nat_gateway_ips, (var.single_nat_gateway ? 0 : count.index))}"
  subnet_id     = "${element(aws_subnet.public.*.id, (var.single_nat_gateway ? 0 : count.index))}"

  tags = "${merge(map("Name", format("%s-%s", var.name, element(var.azs, (var.single_nat_gateway ? 0 : count.index)))), var.tags, var.nat_gateway_tags)}"

  depends_on = ["aws_internet_gateway.this"]
}

resource "aws_route" "private_nat_gateway" {
  count = "${var.enable_nat_gateway ? local.nat_gateway_count : 0}"

  route_table_id = "${aws_vpc.this.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.this.*.id, count.index)}"

  timeouts {
    create = "5m"
  }
}


##########################
# Route table association
##########################
resource "aws_route_table_association" "private" {
  count = "${length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_vpc.this.main_route_table_id}"
}


resource "aws_route_table_association" "public" {
  count = "${length(var.public_subnets) > 0 ? length(var.public_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}


###########
# Defaults
###########
resource "aws_default_vpc" "this" {
  count = "${var.manage_default_vpc ? 1 : 0}"

  enable_dns_support   = "${var.default_vpc_enable_dns_support}"
  enable_dns_hostnames = "${var.default_vpc_enable_dns_hostnames}"
  enable_classiclink   = "${var.default_vpc_enable_classiclink}"

  tags = "${merge(map("Name", format("%s", var.default_vpc_name)), var.tags, var.default_vpc_tags)}"
}