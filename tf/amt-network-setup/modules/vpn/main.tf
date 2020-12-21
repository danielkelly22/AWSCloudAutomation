resource "aws_customer_gateway" "main_gateway" {
  bgp_asn    = 65134
  ip_address = "172.110.248.250"
  type       = "ipsec.1"

  tags = {
    Name = "amt-${var.environment_affix}-customer-gateway"
  }
}
## aws_vpn_connection can only be created if the remote end is also configured.
## Otherwise this resource will wait for the tunnels to come up before it 
## returns as deployed.  This resource was built by hand and then once the VPN
## connectivity was established "main_vpn_connection" was imported into TF state.
resource "aws_vpn_connection" "main_vpn_connection" {
  customer_gateway_id = aws_customer_gateway.main_gateway.id
  transit_gateway_id  = var.transit_gateway_id
  type                = aws_customer_gateway.main_gateway.type
  static_routes_only  = true


  # TODO: better naming after we verify this won't break the VPN
  tags = {
    Name = "main-amtrust-aws-vpn"
  }
  # tags = merge(var.tags, {
  #   Name = "amt-${var.environment_affix}-vpn-connection"
  # })
}

