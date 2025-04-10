locals {
  role_name        = "analytical-platform-observability"
  trusted_role_arn = "arn:aws:iam::754256621582:role/cloud-platform-irsa-5b82e7568d4a6d7b-live"
}

module "iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.54.1"

  create_role = true

  role_name         = local.role_name
  role_requires_mfa = false

  trusted_role_arns = [local.trusted_role_arn]

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cloudwatch_read_only_access" {
  count = var.enable_cloudwatch_read_only_access ? 1 : 0

  role       = module.iam_role.iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "amazon_prometheus_query_access" {
  count = var.enable_amazon_prometheus_query_access ? 1 : 0

  role       = module.iam_role.iam_role_arn
  policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusQueryAccess"
}

resource "aws_iam_role_policy_attachment" "aws_xray_read_only_access" {
  count = var.enable_aws_xray_read_only_access ? 1 : 0

  role       = module.iam_role.iam_role_arn
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "additional_policies" {
  for_each = { for k, v in var.additional_policies : k => v }

  role       = module.iam_role.iam_role_arn
  policy_arn = each.value
}
