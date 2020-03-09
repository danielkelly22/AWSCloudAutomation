resource "aws_organizations_account" "accounts" {
  for_each = var.accounts

  name      = each.value.name
  email     = each.value.email
  parent_id = local.organizational_units[each.value.ou_key]

  role_name = each.value.role_name
  lifecycle {
    ignore_changes = [role_name]
  }
}
