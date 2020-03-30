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
}

data "aws_kms_alias" "vault-example" {
  name = "alias/${var.auto_unseal_kms_key_alias}"
}

module "vault_cluster" {
  source = "./vault-cluster"

  cluster_name  = var.vault_cluster_name
  cluster_size  = var.vault_cluster_size
  instance_type = var.vault_instance_type
  ami_id        = "ami-0999ee68a7d242ccf"

  vpc_id     = var.vpc_id
  subnet_ids = ["subnet-052ab56c90a5d0a96"]

  auto_unseal_kms_key_arn = data.aws_kms_alias.vault-example.target_key_arn

  allowed_ssh_cidr_blocks            = ["0.0.0.0/0"]
  allowed_inbound_cidr_blocks        = ["0.0.0.0/0"]
  allowed_inbound_security_group_ids = []
  ssh_key_name                       = var.ssh_key_name
}

module "consul_cluster" {
  source = "./consul-cluster"

  cluster_name  = var.consul_cluster_name
  cluster_size  = var.consul_cluster_size
  instance_type = var.consul_instance_type
  ami_id        = "ami-0921928816d6cdc20"

  # The EC2 Instances will use these tags to automatically discover each other and form a cluster
  cluster_tag_key   = var.consul_cluster_tag_key
  cluster_tag_value = var.consul_cluster_name

  vpc_id     = var.vpc_id
  subnet_ids = ["subnet-052ab56c90a5d0a96"]

  allowed_ssh_cidr_blocks     = ["0.0.0.0/0"]
  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
  ssh_key_name                = var.ssh_key_name
}

# IAM policy that allows auto clustering
resource "aws_iam_role_policy" "auto_discover_cluster" {
  for_each = {
    0 = module.vault_cluster.iam_role_id,
    1 = module.consul_cluster.iam_role_id
  }
  name   = "auto-discover-cluster"
  role   = each.value
  policy = data.aws_iam_policy_document.auto_discover_cluster.json
}

data "aws_iam_policy_document" "auto_discover_cluster" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "autoscaling:DescribeAutoScalingGroups",
    ]

    resources = ["*"]
  }
}

data "aws_region" "current" {
}
