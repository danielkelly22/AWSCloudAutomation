variable "tags" {
  description = "The tags to apply to the resources"
  type        = map(string)
}

variable "palo_ami" {
  type = string
}

variable "server_key_name" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "private_subnet_id" {
  type = string
}

variable "management_subnet_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "m5.xlarge"
}

variable "instance_volume_type" {
  type    = string
  default = "gp2"
}

variable "instance_volume_size" {
  type    = number
  default = 60
}
