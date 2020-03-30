################################################
# main
################################################
variable "tfe_hostname" {
  type        = string
  description = "Hostname of TFE instance"
}

variable "friendly_name_prefix" {
  type        = string
  description = "String value for friendly name prefix ensuring unique AWS resource names and tags"
}

variable "common_tags" {
  type        = map(string)
  description = "Map of common tags for taggable AWS resources"
  default     = {}
}

variable "tfe_release_sequence" {
  type        = string
  description = "TFE application version release sequence number within Replicated (empty string for latest version)"
  default     = ""
}

variable "tfe_bootstrap_bucket" {
  type        = string
  description = "Existing S3 bucket where tfe-license.rli is housed"
}

################################################
# network
################################################
variable "vpc_id" {
  type        = string
  description = "VPC ID that TFE will be deployed into"
}

variable "alb_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to use for Application Load Balancer (ALB)"
}

variable "ec2_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to use for EC2 instance - preferably private subnets"
}

variable "tls_port" {
  description = "The port used to allow HTTPS traffic inbound"
  default     = 443
}

variable "redirect_port" {
  description = "The port used to redirect HTTP traffic to HTTPS inbound"
  default     = 80
}

variable "replicated_port" {
  description = "The port used to allow traffic to TFE Replicated admin console"
  default     = 8800
}

variable "ssh_port" {
  description = "The port used for SSH connections"
  type        = number
  default     = 22
}

variable "postgresql_port" {
  description = "The port used to allow PostgreSQL traffic inbound to TFE RDS from tfe Security Group"
  type        = number
  default     = 5432
}

# variable "route53_hosted_zone_name" {
#   type        = string
#   description = "Route53 Hosted Zone where TFE alias record and cert validation record will reside"
# }

################################################
# security
################################################
variable "tfe_ingress_cidr_web_allow" {
  type        = list(string)
  description = "List of CIDRs to allow web traffic ingress to TFE Application Load Balancer"
}

variable "tfe_ingress_cidr_ec2_allow" {
  type        = list(string)
  description = "List of CIDRs to allow SSH ingress to TFE EC2 instance"
}

variable "tfe_ec2_key_pair" {
  type        = string
  description = "SSH key pair for TFE EC2 instance"
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of KMS key to encrypt TFE RDS and RDS resources"
}

variable "secrets_mgmt" {
  type        = string
  description = "Secrets Management tool used for TFE bootstrap secrets. Default of 'none' will result in secrets being computed by random_string. Other options: 'vault', 'aws'"
}

variable "aws_secret_arn" {
  type        = string
  description = "ARN of secret stored in AWS Secrets Manager. Defaults to empty. Only needed if secrets_mgmt variable is set to 'aws'"
}

################################################
# compute
################################################
variable "tfe_os_type" {
  type        = string
  description = "OS type for TFE EC2 instance"
}

variable "tfe_ami" {
  type        = string
  description = "AMI ID for TFE EC2 instance"
}

variable "tfe_instance_size" {
  type        = string
  description = "EC2 instance type for TFE server"
  default     = "m5.large"
}

################################################
# storage
################################################
variable "rds_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs to use for RDS"
}

variable "rds_storage_capacity" {
  type        = string
  description = "Size capacity (GB) of RDS Postgres database"
  default     = 50
}

variable "rds_engine_version" {
  type        = string
  description = "Version of PostgreSQL for RDS engine"
  default     = "9.6"
}

variable "rds_multi_az" {
  type        = string
  description = "Set to true to enable multiple availability zone RDS"
  default     = "false"
}

variable "rds_instance_size" {
  type        = string
  description = "Instance size for RDS"
  default     = "db.m4.large"
}
