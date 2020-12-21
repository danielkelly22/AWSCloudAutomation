# TODO: Only allow vpc attachments to the replication vpc or drtest isolated vpc.

resource "aws_iam_user" "cloudendure" {
  name = var.cloudendure_iam_user_name
  path = "/system/"

  tags = merge(var.tags, {
    "Name" = var.cloudendure_iam_user_name
  })
}

resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.cloudendure.name
}

resource "aws_iam_policy" "cloudendure_group_1" {
  name   = "cloudendure_group_1_${var.aws_region}"
  path   = "/"
  policy = templatefile(
    "${path.module}/policies/cloudendure_group_1.json",
    {
      aws_account_id = var.aws_account_id
      aws_region = var.aws_region
    }
  )
}

resource "aws_iam_user_policy_attachment" "cloudendure_group_1_attach" {
  user       = aws_iam_user.cloudendure.name
  policy_arn = aws_iam_policy.cloudendure_group_1.arn
}

resource "aws_iam_policy" "cloudendure_group_2" {
  name   = "cloudendure_group_2_${var.aws_region}"
  path   = "/"

  policy = templatefile(
    "${path.module}/policies/cloudendure_group_2.json",
    {
      aws_account_id = var.aws_account_id
      aws_region = var.aws_region
    }
  )
}
resource "aws_iam_user_policy_attachment" "cloudendure_group_2_attach" {
  user       = aws_iam_user.cloudendure.name
  policy_arn = aws_iam_policy.cloudendure_group_2.arn
}

resource "aws_iam_policy" "cloudendure_group_3" {
  name   = "cloudendure_group_3_${var.aws_region}"
  path   = "/"
  policy = templatefile(
    "${path.module}/policies/cloudendure_group_3.json",
    {
      aws_account_id = var.aws_account_id
      aws_region = var.aws_region
    }
  )
}
resource "aws_iam_user_policy_attachment" "cloudendure_group_3_attach" {
  user       = aws_iam_user.cloudendure.name
  policy_arn = aws_iam_policy.cloudendure_group_3.arn
}

resource "aws_iam_policy" "cloudendure_group_4" {
  name   = "cloudendure_group_4_${var.aws_region}"
  path   = "/"
  policy = templatefile(
    "${path.module}/policies/cloudendure_group_4.json",
    {
      aws_account_id = var.aws_account_id
      aws_region = var.aws_region
    }
  )
}

resource "aws_iam_user_policy_attachment" "cloudendure_group_4_attach" {
  user       = aws_iam_user.cloudendure.name
  policy_arn = aws_iam_policy.cloudendure_group_4.arn
}

resource "aws_iam_policy" "cloudendure_group_5" {
  name   = "cloudendure_group_5_${var.aws_region}"
  path   = "/"
  policy = templatefile(
    "${path.module}/policies/cloudendure_group_5.json",
    {
      aws_account_id = var.aws_account_id
      aws_region = var.aws_region
    }
  )
}

resource "aws_iam_user_policy_attachment" "cloudendure_group_5_attach" {
  user       = aws_iam_user.cloudendure.name
  policy_arn = aws_iam_policy.cloudendure_group_5.arn
}
