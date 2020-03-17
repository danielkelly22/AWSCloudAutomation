output "vpc_id" {
  description = "The ID of the VPC created."
  value       = aws_vpc.vpc.id
}

output "subnet_ids" {
  value = { for key, subnet in aws_subnet.subnets : key => subnet.id }
}

output "transit_gateway_attachment_id" {
  value = data.null_data_source.hacky_way_to_ensure_that_the_accepter_completes.outputs.tgw_attachment_id
}
