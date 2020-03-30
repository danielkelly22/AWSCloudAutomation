terraform {
  required_version = ">= 0.12"
  backend "remote" {
    hostname     = "tfe.amtrustgroup.com"
    organization = "AmTrust"

    workspaces {
      name = "SharedServices"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::207476187760:role/SharedSvcRoot"
  }
}

data "aws_ami" "centos" {
  owners      = ["679593333241"]
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "awx_test" {
  ami                    = data.aws_ami.centos.id
  key_name               = "TFE_key"
  instance_type          = "t2.micro"
  subnet_id              = "subnet-09670609fe5a4ce69"
  vpc_security_group_ids = [aws_security_group.tfe_ec2_allow.id]

  tags = {
    Name            = "ADO Build Agent"
    awx-managed     = true
    ado-build-agent = true
  }
}

resource "aws_security_group" "tfe_ec2_allow" {
  name   = "awx-allow"
  vpc_id = "vpc-0709e462c67f9a26e"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.10.225.150/32"]
    description = "Allow SSH inbound from AWX"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all traffic outbound"
  }
}
