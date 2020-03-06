resource "aws_config_configuration_aggregator" "organization" {
  name = "amt-config-aggregator" # Required

  organization_aggregation_source {
    all_regions = true
    role_arn    = aws_iam_role.organization.arn
  }

  depends_on = [aws_iam_role_policy_attachment.organization]
}

resource "aws_iam_role" "organization" {
  name = "amt-config-role"

  assume_role_policy = file("${path.module}/policies/iam-assume-config-service-role.json")
}

resource "aws_iam_role_policy_attachment" "organization" {
  role       = aws_iam_role.organization.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}
