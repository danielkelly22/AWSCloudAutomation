provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::207476187760:role/SharedSvcRoot"
  }
}

################################################
# IAM
################################################
resource "aws_iam_role" "tfe_instance_role" {
  name               = "${var.friendly_name_prefix}-tfe-instance-role"
  path               = "/"
  assume_role_policy = file("${path.module}/templates/tfe-instance-role.json")

  tags = merge({ Name = "${var.friendly_name_prefix}-tfe-instance-role" }, var.common_tags)
}

resource "aws_iam_role_policy" "tfe_instance_role_policy" {
  name   = "${var.friendly_name_prefix}-tfe-instance-role-policy"
  policy = data.template_file.instance_role_policy.rendered
  role   = aws_iam_role.tfe_instance_role.id
}

resource "aws_iam_instance_profile" "tfe_instance_profile" {
  name = "${var.friendly_name_prefix}-tfe-instance-profile"
  path = "/"
  role = aws_iam_role.tfe_instance_role.name
}

################################################
# Security Groups
################################################
resource "aws_security_group" "tfe_alb_allow" {
  name   = "${var.friendly_name_prefix}-tfe-web-alb-allow"
  vpc_id = var.vpc_id
  tags   = merge({ Name = "${var.friendly_name_prefix}-tfe-web-alb-allow" }, var.common_tags)

  dynamic "ingress" {
    for_each = [var.tls_port, var.redirect_port, var.replicated_port]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.tfe_ingress_cidr_web_allow
    }
  }
}

resource "aws_security_group" "tfe_ec2_allow" {
  name   = "tfe-ec2-allow"
  vpc_id = var.vpc_id
  tags   = merge({ Name = "tfe-ec2-allow" }, var.common_tags)

  dynamic "ingress" {
    for_each = [var.tls_port, var.replicated_port]
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [aws_security_group.tfe_alb_allow.id]
    }
  }

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = var.tfe_ingress_cidr_ec2_allow
    description = "Allow SSH inbound to TFE EC2 instance from list of CIDRs specified by the user"
  }
}

resource "aws_security_group" "tfe_rds_allow" {
  name   = "tfe-rds-allow"
  vpc_id = var.vpc_id
  tags   = merge({ Name = "tfe-rds-allow" }, var.common_tags)

  ingress {
    from_port       = var.postgresql_port
    to_port         = var.postgresql_port
    protocol        = "tcp"
    security_groups = [aws_security_group.tfe_ec2_allow.id]
    description     = "Allow PostgreSQL traffic inbound to TFE RDS from tfe Security Group"
  }
}


resource "aws_security_group" "tfe_outbound_allow" {
  name   = "tfe-outbound-allow"
  vpc_id = var.vpc_id
  tags   = merge({ Name = "tfe-outbound-allow" }, var.common_tags)

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all traffic outbound from TFE"
  }
}

################################################
# Auto Scaling
################################################
resource "aws_launch_template" "tfe_lt" {
  name          = "${var.friendly_name_prefix}-tfe-ec2-primary-lt"
  image_id      = var.tfe_ami
  instance_type = var.tfe_instance_size
  key_name      = var.tfe_ec2_key_pair
  user_data     = data.template_cloudinit_config.tfe_cloud_config.rendered

  iam_instance_profile {
    name = aws_iam_instance_profile.tfe_instance_profile.name
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 50
    }
  }

  vpc_security_group_ids = [
    aws_security_group.tfe_ec2_allow.id,
    aws_security_group.tfe_rds_allow.id,
    aws_security_group.tfe_outbound_allow.id
  ]

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      { Name = "${var.friendly_name_prefix}-tfe-ec2-primary" },
      { Type = "autoscaling-group" },
      var.common_tags
    )
  }

  tags = merge({ Name = "${var.friendly_name_prefix}-tfe-ec2-launch-template" }, var.common_tags)
}

resource "aws_autoscaling_group" "tfe_asg" {
  name                      = "${var.friendly_name_prefix}-tfe-asg"
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = var.ec2_subnet_ids
  health_check_grace_period = 600
  health_check_type         = "ELB"

  launch_template {
    id      = aws_launch_template.tfe_lt.id
    version = "$Latest"
  }

  target_group_arns = [
    aws_lb_target_group.tfe_tg_443.arn,
    aws_lb_target_group.tfe_tg_8800.arn
  ]
}

################################################
# Load Balancing
################################################
resource "aws_lb" "tfe_alb" {
  name               = "${var.friendly_name_prefix}-tfe-web-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.tfe_alb_allow.id,
    aws_security_group.tfe_outbound_allow.id
  ]

  subnets = var.alb_subnet_ids

  tags = merge({ Name = "${var.friendly_name_prefix}-tfe-web-alb" }, var.common_tags)
}

# resource "aws_lb_listener" "tfe_listener_443" {
#   load_balancer_arn = aws_lb.tfe_alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = aws_acm_certificate.tfe_cert.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.tfe_tg_443.arn
#   }

#   depends_on = [aws_acm_certificate.tfe_cert]
# }

resource "aws_lb_listener" "tfe_listener_80_rd" {
  load_balancer_arn = aws_lb.tfe_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# resource "aws_lb_listener" "tfe_listener_8800" {
#   load_balancer_arn = aws_lb.tfe_alb.arn
#   port              = 8800
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = aws_acm_certificate.tfe_cert.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.tfe_tg_8800.arn
#   }

#   depends_on = [aws_acm_certificate.tfe_cert]
# }

resource "aws_lb_target_group" "tfe_tg_443" {
  name     = "tfe-alb-tg-443"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/_health_check"
    protocol            = "HTTPS"
    matcher             = 200
    healthy_threshold   = 5
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 15
  }

  tags = merge(
    { Name = "tfe-alb-tg-443" },
    { Description = "ALB Target Group for TFE web application HTTPS traffic" },
    var.common_tags
  )
}

resource "aws_lb_target_group" "tfe_tg_8800" {
  name     = "tfe-alb-tg-8800"
  port     = 8800
  protocol = "HTTPS"
  vpc_id   = var.vpc_id

  health_check {
    path     = "/authenticate"
    protocol = "HTTPS"
    matcher  = 200
  }

  tags = merge(
    { Name = "tfe-alb-tg-8800" },
    { Description = "ALB Target Group for TFE/Replicated web admin console traffic over port 8800" },
    var.common_tags
  )
}

################################################
# S3
################################################
resource "aws_s3_bucket" "tfe_app" {
  bucket = "${var.friendly_name_prefix}-tfe-app-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}"
  region = data.aws_region.current.name

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.kms_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = merge(
    { Name = "${var.friendly_name_prefix}-tfe-app-${data.aws_caller_identity.current.account_id}" },
    { Description = "TFE application blob storage" },
    var.common_tags
  )
}

resource "aws_s3_bucket_policy" "tfe_app_bucket_policy" {
  bucket     = aws_s3_bucket.tfe_app.id
  policy     = data.template_file.tfe_app_bucket_policy.rendered
  depends_on = [aws_s3_bucket_public_access_block.tfe_app_bucket_block_public]
}

resource "aws_s3_bucket_public_access_block" "tfe_app_bucket_block_public" {
  bucket = aws_s3_bucket.tfe_app.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true

  depends_on = [aws_s3_bucket.tfe_app]
}

################################################
# RDS
################################################
resource "aws_db_subnet_group" "tfe_rds_subnet_group" {
  name       = "${var.friendly_name_prefix}-tfe-db-subnet-group"
  subnet_ids = var.rds_subnet_ids

  tags = merge(
    { Name = "${var.friendly_name_prefix}-tfe-rds-subnet-group" },
    { Description = "Subnets for TFE PostgreSQL RDS instance" },
    var.common_tags
  )
}

resource "random_password" "rds_password" {
  length  = 24
  special = false
}

resource "aws_db_instance" "tfe_rds" {
  allocated_storage         = var.rds_storage_capacity
  identifier                = "${var.friendly_name_prefix}-tfe-rds-${data.aws_caller_identity.current.account_id}"
  final_snapshot_identifier = "${var.friendly_name_prefix}-tfe-rds-${data.aws_caller_identity.current.account_id}-final-snapshot"
  storage_type              = "gp2"
  engine                    = "postgres"
  engine_version            = var.rds_engine_version
  db_subnet_group_name      = aws_db_subnet_group.tfe_rds_subnet_group.id
  name                      = "tfe"
  storage_encrypted         = true
  kms_key_id                = var.kms_key_arn
  multi_az                  = var.rds_multi_az
  instance_class            = var.rds_instance_size
  username                  = "tfe"
  password                  = random_password.rds_password.result

  vpc_security_group_ids = [
    aws_security_group.tfe_rds_allow.id
  ]

  tags = merge(
    { Name = "${var.friendly_name_prefix}-tfe-rds-${data.aws_caller_identity.current.account_id}" },
    { Description = "TFE PostgreSQL database storage" },
    var.common_tags
  )
}

