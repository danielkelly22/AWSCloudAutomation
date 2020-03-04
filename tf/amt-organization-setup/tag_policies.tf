resource "aws_organizations_policy" "require_costcenter_tag" {
  name        = "AMTTagLocation"
  description = "Requires the 'CostCenter' tag on all resources."
  type        = "TAG_POLICY"

  content = file("${path.module}/policies/tag-require-costcenter.json")
}

resource "aws_organizations_policy_attachment" "require_costcenter_tag" {
  policy_id = aws_organizations_policy.require_costcenter_tag.id
  target_id = aws_organizations_organizational_unit.vendormanaged.id
}
