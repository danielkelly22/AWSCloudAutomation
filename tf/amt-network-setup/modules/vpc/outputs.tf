output "vpc_id" {
  description = "The ID of the VPC created."
  value       = aws_vpc.vpc.id
}
output "transited_subnets" {
  description = "The subnets that have the transit gateway attached. Which subnets don't really matter as long as there's one per availability zone."
  value       = local.transit_subnet_ids
}
