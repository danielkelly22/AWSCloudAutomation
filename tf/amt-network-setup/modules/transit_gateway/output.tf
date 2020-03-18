output "tgw_id" {
  description = "The ID of the transit gateway that was created."
  value       = aws_ec2_transit_gateway.tgw.id

  # These have to be done before anything can try to attach to the transit gateway
  depends_on = [
    aws_ram_principal_association.tgw_org_principal,
    aws_ram_resource_association.transit_gateway_association
  ]
}
