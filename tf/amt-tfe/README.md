# TFE v4 Prod Install on AWS

This module is for deploying a production TFE v4 instance in AWS. The _Operational Mode_ is **External Services** and the _Installation Mode_ is **Online**.

## Requirements

- Terraform >= 0.12.6
- TFE license file from Replicated

## Prerequisites

- AWS account
- VPC with private subnets (and public subnets only if Application Load Balancer will be Internet-facing) that have outbound Internet connectivity
- "Bootstrap" S3 bucket containing `tfe-license.rli` file at the root of it _(to be retrieved by TFE EC2 instance within `user_data`)_
- [Public] Route53 Hosted Zone _(needs to be **public** for DNS certificate validation method to be fully automated within this Terraform module)_
- KMS key _(used for encrypting S3 and RDS)_
- EC2 SSH key pair
- TFE Replicated admin console password and embedded Vault encryption password (see [AWS Secrets Manager](###AWS-Secrets-Manager) section below)

### AWS Secrets Manager

TFE requires a few settings to bootstrap fully unattended. You can use AWS Secrets Manager secret for this.

- AWS Secret Manager ARN containing two secrets:
  1. **`repl_password`** - TFE Replicated admin console password: this is the password to unlock the Replicated admin console. In order to achieve full automation, this value needs to be placed in `/etc/replicated.conf` on the TFE instance, with a key name of `DaemonAuthenticationPassword`.
  2. **`enc_password`** - Embedded Vault encryption password: this only applies to deployments leveraging the embedded Vault _(which is the extremely highly recommended best practice at this point)_. This is considered _"secret zero"_ that encrypts the single Vault unseal key and Vault root token before they are written into the TFE PostgreSQL database. In order to achieve full automation, this value needs to be placed in a `tfe-settings.json` file on the TFE instance, with a key name of `enc_password`.

## Usage

```hcl
module "tfe" {

  tfe_hostname               = var.tfe_hostname
  friendly_name_prefix       = var.friendly_name_prefix
  common_tags                = var.common_tags
  tfe_release_sequence       = var.tfe_release_sequence
  tfe_bootstrap_bucket       = var.tfe_bootstrap_bucket
  vpc_id                     = var.vpc_id
  alb_subnet_ids             = var.alb_subnet_ids
  ec2_subnet_ids             = var.ec2_subnet_ids
  route53_hosted_zone_name   = var.route53_hosted_zone_name
  tfe_ingress_cidr_web_allow = var.tfe_ingress_cidr_web_allow
  tfe_ingress_cidr_ec2_allow = var.tfe_ingress_cidr_ec2_allow
  kms_key_arn                = var.kms_key_arn
  secrets_mgmt               = "aws"
  aws_secret_arn             = var.aws_secret_arn
  tfe_ec2_key_pair           = var.tfe_ec2_key_pair
  tfe_os_type                = var.tfe_os_type
  tfe_ami                    = var.tfe_ami
  rds_subnet_ids             = var.rds_subnet_ids
}
```

After the Terraform configuration has been applied and the EC2 instance has been spawned by the Autoscaling Group and is finished initializing, you should be able to log in to the TFE Replicated admin console by accessing the `tfe_admin_console_url` value. Ensure that the Dashboard is showing the application as **Started** in the left pane. From there, click the **Open** link to create the initial admin user and begin configuring the application.

### Inputs

| Variable | Type | Description | Default Value |
| -------- | ---- | ----------- | ------------- |
| tfe_hostname | string | Hostname of TFE instance | |
| friendly_name_prefix | string | String value for friendly name prefix ensuring unique AWS resource names and tags | |
| common_tags | map | Map of common tags for taggable AWS resources | {} |
| tfe_release_sequence | string | TFE application version release sequence number within Replicated _(leave blank for latest version)_ | "" |
| tfe_bootstrap_bucket | string | S3 bucket containing `tfe-license.rli` file that the EC2 instance will retrieve during `user_data` | |
| vpc_id | string | VPC ID that TFE will be deployed into | |
| alb_subnet_ids | string | List of subnet IDs to use for Application Load Balancer (ALB) | |
| ec2_subnet_ids | string | List of subnet IDs to use for EC2 instance - preferably private subnets | |
| route53_hosted_zone_name | string | Route53 Hosted Zone where TFE alias record and cert validation record will reside | |
| tfe_ingress_cidr_web_allow | list | List of CIDRs to allow web traffic ingress to TFE Application Load Balancer | |
| tfe_ingress_cidr_ec2_allow | list | List of CIDRs to allow SSH ingress to TFE EC2 instance | |
| kms_key_arn | string | ARN of KMS key to encrypt TFE RDS and RDS resources | |
| tfe_ec2_key_pair | string | SSH key pair for TFE EC2 instance | |
| secrets_mgmt | string | Which secrets management tool to use for TFE bootstrap process (options: _aws_, _vault_, _none_) | aws |
| aws_secret_arn | string | ARN of AWS secret containing values to be retrieved during TFE EC2 bootstrap | |
| tfe_os_type | string | OS type for TFE EC2 instance (options: _amzn2_, _ubuntu_, _centos_, _rhel_) | |
| tfe_ami | string | AMI ID for TFE EC2 instance | |
| tfe_instance_size | string | EC2 instance type for TFE server | m5.large |
| rds_subnet_ids | list | Subnet IDs to use for RDS | |
| rds_storage_capacity | string | Size capacity (GB) of RDS Postgres database | 50 |
| rds_engine_version | string | Version of PostgreSQL for RDS engine | 9.6 |
| rds_multi_az | string | Set to true to enable multiple availability zone RDS | true |
| rds_instance_size | string | Instance size for RDS | db.m4.large |

### Outputs

| Output | Description |
| -------- | ---- |
| tfe_app_url | TFE Application URL |
| tfe_admin_console_url | TFE Replicated admin console dashboard URL |
| tfe_alb_dns_name | DNS name of TFE Application Load Balancer |
| tfe_app_bucket_name | TFE application S3 bucket name |

## Roadmap

- Add additional OS support for CentOS, ~~Ubuntu~~, and RHEL
- Add conditionals for secrets management tool and `user_data` script arguments _(right now `aws` is all that is supported) - `vault` coming soon)_
- Add option for creating SSH key within the module instead of requiring one as a prerequisite
