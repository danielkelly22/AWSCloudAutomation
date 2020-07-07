variable "region" {
  description = "The region to deploy to"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to deploy into"
  type        = string
}

variable "ami_id" {
  description = "The ID of the AMI to run in the cluster. This should be an AMI built from the Packer template under examples/vault-consul-ami/vault-consul.json."
  type        = string
}

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair."
  type        = string
}

variable "vault_cluster_name" {
  description = "What to name the Vault server cluster and all of its associated resources"
  type        = string
}

variable "vault_cluster_size" {
  description = "The number of Vault server nodes to deploy. We strongly recommend using 3 or 5."
  type        = number
}

variable "vault_instance_type" {
  description = "The type of EC2 Instance to run in the Vault ASG"
  type        = string
}

variable "asg_subnet_ids" {
  description = "The subnet IDs into which the EC2 Instances should be deployed. Must span at least two availability zones"
  type        = list(string)
}

variable "api_port" {
  description = "The port to use for Vault API calls"
  default     = 8200
}

variable "cluster_port" {
  description = "The port to use for Vault server-to-server communication."
  default     = 8201
}

variable "ssh_port" {
  description = "The port used for SSH connections."
  default     = 22
}
