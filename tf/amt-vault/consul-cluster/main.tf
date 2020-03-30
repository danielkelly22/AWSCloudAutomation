locals {
  tcp_ports = [
    var.server_rpc_port,
    var.cli_rpc_port,
    var.serf_wan_port,
    var.serf_lan_port,
    var.http_api_port,
    var.dns_port
  ]

  udp_ports = [
    var.serf_wan_port,
    var.serf_lan_port,
    var.dns_port
  ]
}

################################################
# Auto Scaling
################################################
resource "aws_autoscaling_group" "autoscaling_group" {
  name                      = var.cluster_name
  min_size                  = var.cluster_size
  max_size                  = var.cluster_size
  desired_capacity          = var.cluster_size
  vpc_zone_identifier       = var.subnet_ids
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type

  launch_template {
    id      = aws_launch_template.launch_configuration.id
    version = "$Latest"
  }

  availability_zones        = var.availability_zones
  termination_policies      = [var.termination_policies]
  wait_for_capacity_timeout = var.wait_for_capacity_timeout

  tags = flatten(
    [
      {
        key                 = "Name"
        value               = var.cluster_name
        propagate_at_launch = true
      },
      {
        key                 = var.cluster_tag_key
        value               = var.cluster_tag_value
        propagate_at_launch = true
      },
      var.tags,
    ]
  )
}

resource "aws_launch_template" "launch_configuration" {
  name          = var.cluster_name
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.ssh_key_name

  iam_instance_profile {
    name = element(concat(
      aws_iam_instance_profile.instance_profile.*.name, [""]),
      0,
    )
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 50
      delete_on_termination = true
    }
  }

  vpc_security_group_ids = [
    aws_security_group.lc_security_group.id
  ]
}

################################################
# Security Group
################################################
resource "aws_security_group" "lc_security_group" {
  name        = var.cluster_name
  description = "Security group for the ${var.cluster_name} launch configuration"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      "Name" = var.cluster_name
    },
    var.security_group_tags,
  )

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = var.ssh_port
    to_port         = var.ssh_port
    protocol        = "tcp"
    cidr_blocks     = var.allowed_ssh_cidr_blocks
    security_groups = var.allowed_ssh_security_group_ids
  }

  dynamic "ingress" {
    for_each = local.tcp_ports
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      cidr_blocks     = var.allowed_inbound_cidr_blocks
      security_groups = var.allowed_inbound_security_group_ids
      self            = true
    }
  }

  dynamic "ingress" {
    for_each = local.udp_ports
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "udp"
      cidr_blocks     = var.allowed_inbound_cidr_blocks
      security_groups = var.allowed_inbound_security_group_ids
      self            = true
    }
  }
}

################################################
# IAM
################################################
resource "aws_iam_instance_profile" "instance_profile" {
  name = var.cluster_name
  path = var.instance_profile_path
  role = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "instance_role" {
  name               = var.cluster_name
  assume_role_policy = data.aws_iam_policy_document.instance_role.json
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
