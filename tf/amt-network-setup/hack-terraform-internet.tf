# #----------------------------------------------------------------------------
# # Support SNAT for Terraform
# #  * Description - 
# #      This allows internet egress + ingress for Terraform. Without this,
# #      only egress is supported.
# #  * Conditions for Removal - 
# #      Once the Palo Alto servers are properly configured, this can be
# #      removed.
# #  * Notes -
# #      * The outbound internet route is currently commented out in the file
# #        tgs-routes.shared.tf. When you delete this, re-enable that route.
# #      * Remove the entries in internet_connected_subnets from the file
# #        vpc-shared.auto.tfvars.
# #----------------------------------------------------------------------------

# # tf import aws_internet_gateway.terraform igw-0d900c3c9f361f88d
# resource "aws_internet_gateway" "terraform" {
#   vpc_id = module.shared_vpc.vpc_id
# }

# # tf import aws_route_table.terraform rtb-00c2eab0edf58f10a
# resource "aws_route_table" "terraform" {
#   vpc_id = module.shared_vpc.vpc_id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.gateway.id
#   }

#   dynamic "route" {
#     for_each = local.local_addresses

#     content {
#       cidr_block = each.value
#       gateway_id = module.transit-gateway.transit_gateway_id
#     }
#   }

#   tags = merge(module.shared_tags.tags, {
#     Name = "amt-shared-jump-routes"
#   })
# }

# # tf import 'aws_route_table_association.terraform["amt-shared-jump-subnet-a"]' subnet-068c25baa85c1e54c/rtb-00c2eab0edf58f10a
# # tf import 'aws_route_table_association.terraform["amt-shared-jump-subnet-b"]' subnet-09670609fe5a4ce69/rtb-00c2eab0edf58f10a
# resource "aws_route_table_association" "terraform" {
#   for_each = ["amt-shared-jump-subnet-a", "amt-shared-jump-subnet-b"]

#   route_table_id = aws_route_table.terraform.id
#   subnet_id      = module.shared_vpc.subnet_ids[each.key]
# }
