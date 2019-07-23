
variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = ""
}

variable "vpc_id" {
  description = "Id of vpc"
  default     = ""
}

variable "peer_vpc_id" {
  description = "Id of peer vpc"
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}
