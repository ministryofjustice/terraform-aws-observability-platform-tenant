data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.observability_platform_account_id}:root"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.role_name
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cloudwatch_readonly_access" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "amazon_prometheus_query_access" {
  count = var.enable_prometheus ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusQueryAccess"
}

resource "aws_iam_role_policy_attachment" "xray_readonly_access" {
  count = var.enable_xray ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayReadOnlyAccess"
}

# resource "aws_iam_role_policy_attachment" "athena_readonly_access" {
#   count = var.enable_athena ? 1 : 0

#   role       = aws_iam_role.this.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
# }

# this is purely for testing, at first glance there is not a read only policy for athena
resource "aws_iam_role_policy_attachment" "athena_full_access" {
  count = var.enable_athena ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
}

resource "aws_iam_role_policy_attachment" "additional_policies" {
  for_each = { for k, v in var.additional_policies : k => v }

  role       = aws_iam_role.this.name
  policy_arn = each.value
}
