terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::207476187760:role/SharedSvcRoot"
  }
}

resource "aws_kms_key" "vault" {
  description = "Vault Unseal Key"
}

resource "aws_kms_alias" "vault" {
  name          = "alias/vault-unseal-key"
  target_key_id = aws_kms_key.vault.key_id
}

################################################
# Auto Scaling Group
################################################
resource "aws_autoscaling_group" "vault_autoscaling_group" {
  name                = var.vault_cluster_name
  min_size            = var.vault_cluster_size
  max_size            = var.vault_cluster_size
  desired_capacity    = var.vault_cluster_size
  vpc_zone_identifier = var.asg_subnet_ids

  health_check_grace_period = 300
  health_check_type         = "EC2"

  suspended_processes = [
    "Launch"
  ]

  launch_template {
    id      = aws_launch_template.launch_configuration.id
    version = "$Latest"
  }

  target_group_arns = [
    aws_lb_target_group.vault_tg_8200.arn
  ]
}

resource "aws_launch_template" "launch_configuration" {
  name          = var.vault_cluster_name
  image_id      = var.ami_id
  instance_type = var.vault_instance_type
  key_name      = var.ssh_key_name
  user_data     = data.template_cloudinit_config.vault_config.rendered

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

data "template_cloudinit_config" "vault_config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "tfe_cloud_init.txt"
    content_type = "text/x-shellscript"
    content      = data.template_file.user_data.rendered
  }
}

data "template_file" "user_data" {
  template = file("./user_data.sh")

  vars = {
    kms_key_id = aws_kms_key.vault.id
    region     = var.region
    alb_dns    = aws_lb.vault_alb.dns_name
  }
}

################################################
# Load Balancing
################################################
resource "aws_lb" "vault_alb" {
  name               = "vault-cluster-alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = var.asg_subnet_ids

  security_groups = [
    aws_security_group.lc_security_group.id,
    aws_security_group.vault_alb_allow.id
  ]
}

resource "aws_lb_listener" "vault" {
  load_balancer_arn = aws_lb.vault_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault_tg_8200.arn
  }
}

resource "aws_lb_target_group" "vault_tg_8200" {
  name     = "vault-group"
  port     = 8200
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = {
    vault-cluster = true
  }

  health_check {
    interval          = "5"
    timeout           = "2"
    path              = "/v1/sys/health"
    port              = "8200"
    protocol          = "HTTP"
    matcher           = "200,472,473"
    healthy_threshold = 2
  }
}

################################################
# Load Balancing Security Group
################################################
resource "aws_security_group" "vault_alb_allow" {
  name   = "vault-web-alb-allow"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "lc_security_group" {
  name        = var.vault_cluster_name
  description = "Security group for the ${var.vault_cluster_name} launch configuration"
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
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
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
}

################################################
# IAM
################################################
resource "aws_iam_instance_profile" "instance_profile" {
  name = var.vault_cluster_name
  path = "/"
  role = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "instance_role" {
  name               = var.vault_cluster_name
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

    resources = [aws_kms_key.vault.arn]
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

resource "aws_iam_role_policy" "auto_discover_cluster" {
  name   = "auto-discover-cluster"
  role   = aws_iam_role.instance_role.id
  policy = data.aws_iam_policy_document.auto_discover_cluster.json
}

data "aws_iam_policy_document" "auto_discover_cluster" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "autoscaling:DescribeAutoScalingGroups",
      "elasticloadbalancing:DescribeLoadBalancers",
    ]

    resources = ["*"]
  }
}
