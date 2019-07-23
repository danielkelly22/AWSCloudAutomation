variable "DOMAINNAME" {
  type        = "string"
  description = "Name for the Amazon ES domain that this template will create. Domain names must start with a lowercase letter and must be between 3 and 28 characters. Valid characters are a-z (lowercase only), 0-9."
}
variable "DomainAdminEmail" {
  type        = "string"
  description = "E-mail address of the Elasticsearch admin"
}
variable "CognitoAdminEmail" {
  type        = "string"
  description = "E-mail address of the Cognito admin"
}
variable "ClusterSize" {
  type        = "string"
  description = "Amazon ES cluster size; small (4 data nodes), medium (6 data nodes), large (6 data nodes)"
}
variable "DemoTemplate" {
  type        = "string"
  description = " Deploy template for sample data and logs?"
}

variable "SpokeAccounts" {
  type        = "string"
  description = "Account IDs which you want to allow for centralized logging (comma separated list eg. 11111111,22222222)"
}
variable "DemoVPC" {
  type        = "string"
  description = "CIDR for VPC with sample sources (Only required if you chose 'Yes' above)"
}
variable "DemoSubnet" {
  type        = "string"
  description = "IP address range for subnet with sample web server (Only required if you chose 'Yes' above)"
}
variable "stack_name" {
  type        = "string"
  description = "Unique Cloudformation stack name."
}
variable "tags" {
description = "A map of tags to add to all resources"
  default     = {}
}