variable "vpc_cidr" {
  type        = string
  description = "List of CIDR ranges starting with the VPC then each individual subnet"
}
variable "subnet_names" {
  type = list(string)
}
variable "subnet_ranges" {
  type = list(string)
}
variable "env_name" {
  type        = string
  description = "Environment variable used to name resources"
}
variable "transit_gateway_id" {
  type = string
}
variable "availability_zones" {
  type = list(string)
}
