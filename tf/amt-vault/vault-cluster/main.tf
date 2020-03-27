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

  tag {
    key                 = var.cluster_tag_key
    value               = var.cluster_name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.cluster_extra_tags

    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }
}

resource "aws_launch_template" "launch_configuration" {
  name          = var.cluster_name
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.ssh_key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = [var.ssh_port, var.api_port]
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      cidr_blocks     = var.allowed_inbound_cidr_blocks
      security_groups = var.allowed_inbound_security_group_ids
    }
  }

  dynamic "ingress" {
    for_each = [var.cluster_port, var.api_port]
    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      self      = true
    }
  }

  dynamic "ingress" {
    for_each = ["tcp", "udp"]
    content {
      from_port       = var.serf_lan_port
      to_port         = var.serf_lan_port
      protocol        = ingress.value
      cidr_blocks     = var.allowed_inbound_cidr_blocks
      security_groups = var.allowed_inbound_security_group_ids
      self            = true
    }
  }

  tags = merge(
    {
      "Name" = var.cluster_name
    },
    var.security_group_tags,
  )
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

data "aws_iam_policy_document" "vault_auto_unseal_kms" {
  statement {
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = [var.auto_unseal_kms_key_arn]
  }
}

resource "aws_iam_role_policy" "vault_auto_unseal_kms" {
  name = "vault_auto_unseal_kms"
  role = aws_iam_role.instance_role.id
  policy = element(
    concat(
      data.aws_iam_policy_document.vault_auto_unseal_kms.*.json,
      [""],
    ),
    0,
  )
}

