

resource "aws_vpc_peering_connection" "peering" {
  peer_vpc_id   = "${var.peer_vpc_id}"
  vpc_id        = "${var.vpc_id}"
  auto_accept   = true
  tags = "${merge(map("Name", format("%s", var.name)), var.tags)}"

}

# Lookup requestor VPC so that we can reference the CIDR
data "aws_vpc" "requestor" {
  id    = "${var.vpc_id}"
}
data "aws_vpc" "acceptor" {
  id    = "${var.peer_vpc_id}"
}
resource "aws_route" "primary2secondary" {
  route_table_id = "${data.aws_vpc.requestor.main_route_table_id}"
  destination_cidr_block = "${data.aws_vpc.acceptor.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peering.id}"
}

resource "aws_route" "secondary2primary" {
  route_table_id = "${data.aws_vpc.acceptor.main_route_table_id}"
  destination_cidr_block = "${data.aws_vpc.requestor.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peering.id}"
}