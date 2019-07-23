variable "display_name" {
  type        = "string"
  description = "Name shown in confirmation emails"
}
variable "subscriptions" {
  type        = "list"
  description = "List of Email address to send notifications to"
}
variable "stack_name" {
  type        = "string"
  description = "Unique Cloudformation stack name that wraps the SNS topic."
}
variable "tags" {
description = "A map of tags to add to all resources"
  default     = {}
}