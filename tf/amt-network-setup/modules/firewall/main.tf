###########
# Policy
###########
resource "aws_iam_role" "firewall_ha_role" {
  name               = "FirewallHaRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
            "Service": "ec2.amazonaws.com"
      }      
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "firewall_ha_policy" {
  name   = "FirewallHaPolicy"
  role   = aws_iam_role.firewall_ha_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "ec2:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_instance_profile" "fw_instance_profile" {
  name = "FirewallnstanceProfile"
  role = aws_iam_role.firewall_ha_role.name
}

# deploy palos
########
# FW1
########
resource "aws_network_interface" "fw1_mgmt_interface" {
  subnet_id         = var.management_subnet_id
  source_dest_check = false
  private_ips_count = 1
  tags = {
    Name = "PaloFW1MgmtInterface"
  }
}
resource "aws_network_interface" "fw1_public_interface" {
  subnet_id         = var.public_subnet_id
  source_dest_check = false
  private_ips_count = 1
  tags = {
    Name = "PaloFW1PublicInterface"
  }
}
resource "aws_network_interface" "fw1_private_interface" {
  subnet_id         = var.private_subnet_id
  source_dest_check = false
  private_ips_count = 1
  tags = {
    Name = "PaloFW1PrivateInterface"
  }
}
resource "aws_eip" "fw1_public_eip" {
  vpc = true
  tags = {
    Name = "FwPublicElasticIP1"
  }
}
resource "aws_eip_association" "fw_eip_assoc" {
  network_interface_id = aws_network_interface.fw1_public_interface.id
  allocation_id        = aws_eip.fw1_public_eip.id
}
resource "aws_instance" "fw_instance1" {
  disable_api_termination              = false
  iam_instance_profile                 = aws_iam_instance_profile.fw_instance_profile.name
  instance_initiated_shutdown_behavior = "stop"
  ebs_optimized                        = true
  ami                                  = var.palo_ami
  instance_type                        = var.instance_type

  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_type           = var.instance_volume_type
    delete_on_termination = true
    volume_size           = var.instance_volume_size
  }
  lifecycle {
    ignore_changes = [ebs_block_device, network_interface]
  }

  key_name   = var.server_key_name
  monitoring = false

  tags = merge(var.tags, {
    Name = "TransitVpcPaloFW1"
  })

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.fw1_mgmt_interface.id
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.fw1_public_interface.id
  }

  network_interface {
    device_index         = 2
    network_interface_id = aws_network_interface.fw1_private_interface.id
  }
}
########
# FW2
########
resource "aws_network_interface" "fw2_mgmt_interface" {
  subnet_id         = var.management_subnet_id
  source_dest_check = false
  private_ips_count = 1
  tags = {
    Name = "PaloFW2MgmtInterface"
  }
}

resource "aws_network_interface" "fw2_private_interface" {
  subnet_id         = var.private_subnet_id
  source_dest_check = false
  private_ips_count = 1
  tags = {
    Name = "PaloFW2PrivateInterface"
  }
}

resource "aws_instance" "fw_instance2" {
  disable_api_termination              = false
  iam_instance_profile                 = aws_iam_instance_profile.fw_instance_profile.name
  instance_initiated_shutdown_behavior = "stop"
  ebs_optimized                        = true
  ami                                  = var.palo_ami
  instance_type                        = var.instance_type

  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_type           = var.instance_volume_type
    delete_on_termination = true
    volume_size           = var.instance_volume_size
  }
  lifecycle {
    ignore_changes = [ebs_block_device, network_interface]
  }
  key_name   = var.server_key_name
  monitoring = false

  tags = merge(var.tags, {
    Name = "TransitVpcPaloFW2"
  })

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.fw2_mgmt_interface.id
  }

  network_interface {
    device_index         = 2
    network_interface_id = aws_network_interface.fw2_private_interface.id
  }
}


