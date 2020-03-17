variable "environment_affix" {
  description = "The environment short name to affix to names"
  type        = string
}

variable "transit_gateway_id" {
  description = "The ID of the transit gateway."
  type        = string
}

variable "tags" {
  description = "The tags to apply to the resource"
  type        = map(string)
  default     = {}
}
