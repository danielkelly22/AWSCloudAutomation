resource "aws_ec2_transit_gateway" "this" {
  description                     = "Transit Gateway for VPCs"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = "${merge(map("Name", format("%s", var.name)), var.tags)}"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  
  count = "${length(var.vpc_ids) > 0 ? length(var.vpc_ids) : 0 }"

  subnet_ids         = "${var.subnet_ids[element(var.vpc_ids, count.index)]}"
  
  transit_gateway_id = "${aws_ec2_transit_gateway.this.id}"
  
  vpc_id             = "${element(var.vpc_ids, count.index)}"

  transit_gateway_default_route_table_association = false
  
  transit_gateway_default_route_table_propagation = false
  
  tags = "${merge(map("Name", format("%s-%s", var.name,element(var.vpc_names, count.index))), var.tags)}"

  depends_on = ["aws_ec2_transit_gateway.this"]
}
resource "aws_ec2_transit_gateway_route_table" "this" {
  count = "${length(var.vpc_ids) > 0 ? length(var.vpc_ids) : 0 }"

  transit_gateway_id = "${aws_ec2_transit_gateway.this.id}"
  tags = "${merge(map("Name", format("%s", var.name)), var.tags)}"

  depends_on = ["aws_ec2_transit_gateway.this"]
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  count = "${length(var.vpc_ids) > 0 ? length(var.vpc_ids) : 0 }"
  transit_gateway_attachment_id  = "${element(aws_ec2_transit_gateway_vpc_attachment.this.*.id, count.index)}"
  transit_gateway_route_table_id = "${element(aws_ec2_transit_gateway_route_table.this.*.id, count.index)}"
}