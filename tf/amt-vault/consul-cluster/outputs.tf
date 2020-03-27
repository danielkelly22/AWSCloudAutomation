output "iam_role_id" {
  value       = element(concat(aws_iam_role.instance_role.*.id, [""]), 0)
  description = "This is the id of instance role if enable_iam_setup variable is set to true"
}
