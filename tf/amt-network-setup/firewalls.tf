# # iam roles work
# # The IAM policy must have permissions for the following actions and resources (at a minimum):
# #  - AttachNetworkInterface—For permission to attach an ENI to an instance.
# #  - DescribeNetworkInterface—For fetching the ENI parameters in order to attach an interface to the instance.
# #  - DetachNetworkInterface—For permission to detach the ENI from the EC2 instance.
# #  - DescribeInstances—For permission to obtain information on the EC2 instances in the VPC.
# # #  - Wild card (*)—In the Amazon Resource Name (ARN) field use the * as a wild card.

# resource "aws_iam_role" "firewall_ha_role" {
#   name = "FirewallHaRole"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#         "Action": "sts:AssumeRole",
#         "Effect": "Allow",
#         "Principal": {
#             "Service": "ec2.amazonaws.com"
#       }      
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy" "firewall_ha_policy" {
#   name = "FirewallHaPolicy"
#   role = aws_iam_role.firewall_ha_role.id

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "VisualEditor0",
#       "Effect": "Allow",
#       "Action": [
#         "ec2:*"
#       ],
#       "Resource": "*"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_instance_profile" "fw_instance_profile" {
#   name = "FirewallnstanceProfile"
#   role = aws_iam_role.firewall_ha_role.name
# }

# # deploy palos
# resource "aws_network_interface" "fw_mgmt_interface_1" {
#   subnet_id         = module.transit_vpc.subnet_ids["amt-transit-mgmt-subnet-a"]
#   source_dest_check = false
#   private_ips_count = 1
#   tags = {
#     Name = "PaloFW1MgmtInterface"
#   }
# }
# resource "aws_network_interface" "fw_mgmt_interface_2" {
#   subnet_id         = module.transit_vpc.subnet_ids["amt-transit-mgmt-subnet-a"]
#   source_dest_check = false
#   private_ips_count = 1
#   tags = {
#     Name = "PaloFW2MgmtInterface"
#   }
# }
# resource "aws_network_interface" "fw_public_interface_1" {
#   subnet_id         = module.transit_vpc.subnet_ids["amt-transit-public-subnet-a"]
#   source_dest_check = false
#   private_ips_count = 1
#   tags = {
#     Name = "PaloFW1PublicInterface"
#   }
# }
# resource "aws_network_interface" "fw_private_interface_1" {
#   subnet_id         = module.transit_vpc.subnet_ids["amt-transit-private-subnet-a"]
#   source_dest_check = false
#   private_ips_count = 1
#   tags = {
#     Name = "PaloFW1PrivateInterface"
#   }
# }
# resource "aws_network_interface" "fw_private_interface_2" {
#   subnet_id         = module.transit_vpc.subnet_ids["amt-transit-private-subnet-a"]
#   source_dest_check = false
#   private_ips_count = 1
#   tags = {
#     Name = "PaloFW2PrivateInterface"
#   }
# }
# resource "aws_eip" "fw_public_eip_1" {
#   vpc = true
#   tags = {
#     Name = "FwPublicElasticIP1"
#   }
# }
# resource "aws_instance" "fw_instance1" {
#   disable_api_termination              = false
#   iam_instance_profile                 = aws_iam_instance_profile.fw_instance_profile.name
#   instance_initiated_shutdown_behavior = "stop"
#   ebs_optimized                        = true
#   ami                                  = var.palo_ami
#   instance_type                        = "m5.xlarge"

#   ebs_block_device {
#     device_name           = "/dev/xvda"
#     volume_type           = "gp2"
#     delete_on_termination = true
#     volume_size           = 60
#   }
#   lifecycle {
#     ignore_changes = [ebs_block_device]
#   }

#   key_name   = var.ServerKeyName
#   monitoring = false

#   tags = merge(module.transit_tags.tags, {
#     Name = "TransitVpcPaloFW1"
#   })

#   network_interface {
#     device_index         = 0
#     network_interface_id = aws_network_interface.fw_mgmt_interface_1.id
#   }

#   network_interface {
#     device_index         = 1
#     network_interface_id = aws_network_interface.fw_public_interface_1.id
#   }

#   network_interface {
#     device_index         = 2
#     network_interface_id = aws_network_interface.fw_private_interface_1.id
#   }
# }
# resource "aws_instance" "fw_instance2" {
#   disable_api_termination              = false
#   iam_instance_profile                 = aws_iam_instance_profile.fw_instance_profile.name
#   instance_initiated_shutdown_behavior = "stop"
#   ebs_optimized                        = true
#   ami                                  = var.palo_ami
#   instance_type                        = "m5.xlarge"

#   ebs_block_device {
#     device_name           = "/dev/xvda"
#     volume_type           = "gp2"
#     delete_on_termination = true
#     volume_size           = 60
#   }
#   lifecycle {
#     ignore_changes = [ebs_block_device]
#   }
#   key_name   = var.ServerKeyName
#   monitoring = false

#   tags = merge(module.transit_tags.tags, {
#     Name = "TransitVpcPaloFW2"
#   })

#   network_interface {
#     device_index         = 0
#     network_interface_id = aws_network_interface.fw_mgmt_interface_2.id
#   }

#   network_interface {
#     device_index         = 2
#     network_interface_id = aws_network_interface.fw_private_interface_2.id
#   }
# }

# # resource "aws_eip_association" "fw_eip_assoc" {
# #   network_interface_id = aws_network_interface.fw_public_interface_2.id
# #   allocation_id        = aws_eip.fw_public_eip_1.id
# # }


# module "firewalls" {
#   providers = {
#     aws = aws.shared
#   }

#   source = "./modules/firewall"

#   palo_ami             = var.palo_ami
#   server_key_name      = var.palo_key_name
#   public_subnet_id     = module.transit_vpc.subnet_ids["amt-transit-public-subnet-a"]
#   private_subnet_id    = module.transit_vpc.subnet_ids["amt-transit-private-subnet-a"]
#   management_subnet_id = module.transit_vpc.subnet_ids["amt-transit-mgmt-subnet-a"]

#   tags = module.transit_tags.tags
# }
