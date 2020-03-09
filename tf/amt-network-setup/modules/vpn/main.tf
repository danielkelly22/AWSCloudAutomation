resource "aws_customer_gateway" "main_gateway" {
  bgp_asn    = 65134
  ip_address = "172.110.248.250"
  type       = "ipsec.1"

  tags = {
    Name = "main-amtrust-gateway"
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
  tags = {
    Name = "main-amtrust-aws-vpn"
  }
}

output "vpn_connection_id" {
  value = aws_vpn_connection.main_vpn_connection.id
}
