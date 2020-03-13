variable "accounts" {
  description = "A map of accounts managed in this Terraform."
  type = map(object({
    account_number    = number
    root_role         = string
    environment_affix = string
    email             = string
  }))
}

variable "cloud_governance_business_unit" {
  default = "The business unit for cloud governance resources"
  type    = string
}

variable "cloud_governance_email" {
  description = "The email of the cloud architecture department"
  type        = string
}

variable "cloud_governance_cost_center" {
  description = "The cost center for the cloud architecture department"
  type        = string
}

variable "cloud_governance_application_name" {
  description = "The application name for cloud governance resources"
  type        = string
  default     = "AmTrust AWS Governance"
}

variable "terraform_workspace" {
  description = "The name of the terraform workspace that manages the resources"
  type        = string
  default     = "amt-account-setup"
}
