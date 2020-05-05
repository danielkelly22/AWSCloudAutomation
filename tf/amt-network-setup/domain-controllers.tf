resource "aws_instance" "dc_a" {
  provider          = aws.shared
  ami               = var.dc_ami_id
  instance_type     = var.dc_instance_size
  availability_zone = "us-east-1a"
  subnet_id         = var.dc_subnets.subnet_a_id
  key_name          = "sharedvpckeys"

  lifecycle {
    ignore_changes = [iam_instance_profile]
  }

  tags = merge(module.shared_tags.tags, {
    Name = "amt-sharedservices-dc-a"
  })
}

resource "aws_instance" "dc_b" {
  provider          = aws.shared
  ami               = var.dc_ami_id
  instance_type     = var.dc_instance_size
  availability_zone = "us-east-1b"
  subnet_id         = var.dc_subnets.subnet_b_id
  key_name          = "sharedvpckeys"

  lifecycle {
    ignore_changes = [iam_instance_profile]
  }

  tags = merge(module.shared_tags.tags, {
    Name = "amt-sharedservices-dc-b"
  })
}

  resource "aws_security_group" "amt-dc-allow" {
  name   = "amt-dc-allow"
  vpc_id = "vpc-0709e462c67f9a26e"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow SSH inbound from any private IP"
  }

  ingress {
    from_port   = 123
    to_port     = 123
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow W32Time inbound from any private IP"
  }

  ingress {
    from_port   = 135
    to_port     = 135
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow RCP Endpoint Mapper inbound from any private IP"
  }

  ingress {
    from_port   = 636
    to_port     = 636
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow LDAP SSL inbound from any private IP"
  }

  ingress {
    from_port   = 3268
    to_port     = 3268
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow LDAP GC inbound from any private IP"
  }

   ingress {
    from_port   = 3269
    to_port     = 3269
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow LDAP GC SSL inbound from any private IP"
  }

   ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow DNS inbound from any private IP"
  }

  ingress {
    from_port   = 88
    to_port     = 88
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow DNS inbound from any private IP"
  }

   ingress {
    from_port   = 88
    to_port     = 88
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow Kerberos inbound from any private IP"
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow Kerberos inbound from any private IP"
  }

 ingress {
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow SMB inbound from any private IP"
  }

   ingress {
    from_port   = 445
    to_port     = 445
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow SMB inbound from any private IP"
  }

  ingress {
    from_port   = 464
    to_port     = 464
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow Kerberos password change inbound from any private IP"
  }

  ingress {
    from_port   = 464
    to_port     = 464
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow Kerberos password change inbound from any private IP"
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow RDP inbound from any private IP"
  }

  ingress {
    from_port   = 49152
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow RPC,DFSR,FRS,Netlogon inbound from any private IP"
  }

  ingress {
    from_port   = 49152
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Allow DCOM,RPC,GPO inbound from any private IP"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all traffic outbound"
  }
}
