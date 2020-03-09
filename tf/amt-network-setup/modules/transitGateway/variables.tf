variable "env_name" {
  type        = string
  description = "Environment variable used to name resources"
}
variable "dev_cidr" {
  type = string
}
variable "uat_cidr" {
  type = string
}
variable "prod_cidr" {
  type = string
}
variable "shared_cidr" {
  type = string
}
variable "transit_cidr" {
  type = string
}
variable "vpc_ids" {
  type = list(string)
}
variable "dev_subnet_ids" {
  type = list(string)
}
variable "prod_subnet_ids" {
  type = list(string)
}
variable "uat_subnet_ids" {
  type = list(string)
}
variable "transit_subnet_ids" {
  type = list(string)
}
variable "shared_subnet_ids" {
  type = list(string)
}
variable "vpn_connection_id" {
  type = string
}
