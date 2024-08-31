## ----- locals ----------------------------------------------------------------

locals {
  create_user = var.user_name == "" ? true : false
  bucket_name = var.bucket_prefix == "" ? var.bucket_name : format("%s-%s", var.bucket_prefix, var.bucket_name)
  user_name   = var.user_name == "" ? local.bucket_name : var.user_name
}

## ----- bucket user -----------------------------------------------------------

module "user" {
  source = "../aws_user"
  count  = local.create_user ? 1 : 0

  user_name = local.user_name
  path      = "/bucket-users/"
}

data "aws_iam_user" "bucket" {
  count = local.create_user ? 0 : 1

  user_name = local.user_name
}

## ----- access control --------------------------------------------------------

data "aws_iam_policy_document" "bucket" {
  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      format("%s", aws_s3_bucket.bucket.arn),
    ]
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      format("%s/*", aws_s3_bucket.bucket.arn),
    ]
  }
}

resource "aws_iam_user_policy" "bucket" {
  name   = local.create_user ? format("%s-access", local.user_name) : format("%s-%s-access", local.user_name, local.bucket_name)
  user   = local.user_name
  policy = data.aws_iam_policy_document.bucket.json
}

## ----- bucket ----------------------------------------------------------------

resource "aws_s3_bucket" "bucket" {
  bucket = local.bucket_name
}
