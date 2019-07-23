###################################################################################################################
# Filename   : main.tf
# Summary    : DHCP Option Set module used by Onica to create an AWS Foundtation
# Author     : Sami Meekhaeal (Onica)
# Notes      : Used to create the DHCP Option set
###################################################################################################################
terraform {
    required_version = ">= 0.10.3"
}

###################
# DHCP Options Set
###################
resource "aws_vpc_dhcp_options" "this" {

  domain_name          = "${var.dhcp_options_domain_name}"
  domain_name_servers  = ["${var.dhcp_options_domain_name_servers}"]
  ntp_servers          = ["${var.dhcp_options_ntp_servers}"]
  netbios_name_servers = ["${var.dhcp_options_netbios_name_servers}"]
  netbios_node_type    = "${var.dhcp_options_netbios_node_type}"

  tags = "${merge(map("Name", format("%s", var.name)), var.tags, var.dhcp_options_tags)}"
}

###############################
# DHCP Options Set Association
###############################
resource "aws_vpc_dhcp_options_association" "this" {

  vpc_id          = "${var.vpc_id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.this.id}"
}