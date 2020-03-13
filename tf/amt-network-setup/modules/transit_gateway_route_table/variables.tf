variable "environment_affix" {
  description = "The short environment name to be affixed to resource names."
  type        = string
}

variable "transit_gateway_id" {
  description = "The ID of the transit gateway."
  type        = string
}

variable "transit_gateway_attachment_id" {
  description = "The attachment ID of the resource that this route table serves"
  type        = string
}


variable "attachment_routes" {
  description = "The routes to add to the route table"
  type = map(object({
    cidr_blocks   = set(string)
    attachment_id = string
  }))
}

variable "blackhole_routes" {
  description = "The blackhole CIDR ranges"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "The base set of tags to apply to taggable resources."
  type        = map(string)
  default     = {}
}
