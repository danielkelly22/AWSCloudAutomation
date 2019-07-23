variable "vpc_ids" {
  description = ""
  type = "list"
  default     = [] 
}
variable "vpc_names" {
  description = ""
  type = "list"
  default     = [] 
}
variable "subnet_ids" {
  description = ""
  type = "map"
  default     = {}
}
variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = ""
}
variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}
