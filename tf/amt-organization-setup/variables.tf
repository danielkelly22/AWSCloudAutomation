variable "organization_service_access_principals" {
  description = "A list of the organization level services supported."
  type        = list(string)
  default = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "ram.amazonaws.com",
    "sso.amazonaws.com",
    "tagpolicies.tag.amazonaws.com"
  ]
}

variable "organization_enabled_policy_types" {
  description = "The types of organization-level policies supported."
  type        = list(string)
  default = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY"
  ]
}

variable "organization_feature_set" {
  description = "The feature set of the organization. This should be \"ALL\". This configuration has not been tested for \"CONSOLIDATED_BILLING\""
  type        = string
  default     = "ALL"
}

variable "accounts" {
  description = "Details for the accounts"
  type = map(object({
    name      = string
    email     = string
    ou_key    = string
    role_name = string
  }))
}
