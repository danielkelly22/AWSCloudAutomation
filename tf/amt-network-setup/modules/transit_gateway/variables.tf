variable "description" {
  description = "(Optional )The Transit Gateway description."
  type        = string
  default     = ""
}

variable "tags" {
  description = "The tags to apply. Defaults to empty."
  type        = map(string)
  default     = {}
}

variable "enable_tgw_sharing" {
  description = "Should the TGW be shared via RAM."
  type        = bool
  default     = true
}