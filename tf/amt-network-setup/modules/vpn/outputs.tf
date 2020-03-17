output "vpn_connection_id" {
  value = aws_vpn_connection.main_vpn_connection.id
}

output "transit_gateway_attachment_id" {
  value = aws_vpn_connection.main_vpn_connection.transit_gateway_attachment_id
}
