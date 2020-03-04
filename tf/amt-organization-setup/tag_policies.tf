resource "aws_organizations_policy" "require_costcenter_tag" {
  name        = "AMTTagLocation"
  description = "Requires the 'CostCenter' tag on all resources."
  type        = "TAG_POLICY"

  content = <<EOF
{
  "tags": {
    "costcenter": {
      "tag_key": {
        "@@assign": "CostCenter",
        "@@operators_allowed_for_child_policies": ["@@none"]
      },
      "tag_value": {
        "@@assign": [
          "00000",
          "AC000",
          "AM000",
          "CL000",
          "CM000",
          "CR000",
          "FN000",
          "HR000",
          "IT000",
          "LG000",
          "MK000",
          "OP000",
          "RE000",
          "RM000",
          "SA000",
          "UW000"
        ],
        "@@operators_allowed_for_child_policies": ["@@none"]
      }
    }
  }
}
EOF
}

resource "aws_organizations_policy_attachment" "require_costcenter_tag" {
  policy_id = aws_organizations_policy.require_costcenter_tag.id
  target_id = aws_organizations_organizational_unit.vendormanaged.id
}
