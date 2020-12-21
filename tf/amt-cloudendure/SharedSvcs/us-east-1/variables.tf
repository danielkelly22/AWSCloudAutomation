# TODO: Allow multi-region by looping the policy creation and attachment for the IAM user.
variable "aws_region" {
  description = "The region used for this environment."
  type = string
  default = "us-east-1"
}

variable "organization_accounts" {
  description = "The organization account access details."
  type = map(object({
    account_number  = string
    root_role       = string
    assume_role_arn = string
  }))
  default = {
    shared = {
      account_number  = "207476187760"
      root_role       = "SharedSvcRoot"
      assume_role_arn = "arn:aws:iam::207476187760:role/SharedSvcRoot"
    }
  }
}

variable "networking_business_unit" {
  description = "The business unit for networking"
  type        = string
  default     = "tbd"
}

variable "networking_team_email" {
  description = "The email of the network team"
  type        = string
  default     = "tbd"
}

variable "networking_cost_center" {
  description = "The cost center for the cloud architecture department"
  type        = string
  default     = "IT0000"
}

variable "networking_application_name" {
  description = "The application name for cloud governance resources"
  type        = string
  default     = "Networking"
}

variable "cloud_governance_email" {
  description = "The email of the cloud governance department"
  type        = string
  default     = "amtrustcloudteam@amtrustgroup.com"
}

variable "environment_affix" {
  type = string
  default = "shared-cloudendure_replication"
}