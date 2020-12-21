variable "cloudendure_iam_user_name" {
  description = "The username of the cloudendure IAM user."
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "tags" {
  description = "The tags to apply to the resources"
  type        = map(string)
}
