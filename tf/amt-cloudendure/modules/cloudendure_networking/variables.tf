# e.g. shared-cloudendure-replication
variable "environment_affix" {
  type = string
}

variable "cloudendure_replication_vpc_id" {
  type = string
}

variable "tags" {
  description = "The tags to apply to the resources"
  type        = map(string)
}
