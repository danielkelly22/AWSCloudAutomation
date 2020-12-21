output "vpc_id" {
  description = "The ID of the VPC created."
  value       = aws_vpc.vpc.id
}

output "subnet_ids" {
  description = "A map of the subnets that were created, as {subnet_name => subnet_id, ...}."
  value       = { for key, subnet in aws_subnet.subnets : key => subnet.id }
}

output "isolated_subnet_ids" {
  value = {
    for key, subnet in aws_subnet.subnets : key => subnet.id
    if contains(var.vpc_details.isolated_subnets, key)
  }
}

output "isolated_subnet_defs" {
  description = "A passed through copy of isolated subnet's defs. Used to pull CIDRs for black-holing."
  value = {
    # example:
    # {
    #     k = "amt-shared-drtest-isolated-subnet-a",
    #     v = { the rest of the respective object from vpc-shared.auto.tfvars }
    # }
    for k, v in var.vpc_details.subnets: k => v  # just output the entire definition
    if contains(var.vpc_details.isolated_subnets, k)
  }
}

output "transit_gateway_attachment_id" {
  description = "The ID of the attachment "
  value       = data.null_data_source.hacky_way_to_ensure_that_the_accepter_completes.outputs.tgw_attachment_id
}
