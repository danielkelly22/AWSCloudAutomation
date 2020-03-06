variable "master_guard_duty_id" {
  description = "The ID of the GuardDuty resource in the Security account."
  type        = string
}

variable "master_guard_duty_account_id" {
  description = "The account ID of the account in which the master GuardDuty resource is located."
  type        = string
}

variable "account_email" {
  description = "The email of the account that will be invited to GuardDuty as a member (the current account)."
  type        = string
}
