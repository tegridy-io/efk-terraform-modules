## ----- locals ----------------------------------------------------------------

locals {
  user_name        = var.user_prefix == "" ? var.user_name : format("%s-%s", var.user_prefix, var.user_name)
  aux_policy_count = length(var.aux_policies)
}

## ----- default policy --------------------------------------------------------

data "aws_iam_policy_document" "user" {
  statement {
    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }
}

resource "aws_iam_user_policy" "user" {
  name   = format("%s-general-policy", aws_iam_user.user.name)
  user   = aws_iam_user.user.name
  policy = data.aws_iam_policy_document.user.json
}

## ----- additional policies ---------------------------------------------------

resource "aws_iam_user_policy" "aux" {
  count = local.aux_policy_count

  name   = format("%s-aux-%d", aws_iam_user.user.name, count.index)
  user   = aws_iam_user.user.name
  policy = var.aux_policies[count.index]
}

## ----- user ------------------------------------------------------------------

resource "aws_iam_user" "user" {
  name = local.user_name
  path = var.path
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}
