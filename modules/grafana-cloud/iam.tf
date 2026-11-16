data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.grafana_cloud_aws_account_id}:root"]
    }
    # Grafana Assume Role's shared external ID is the stack ID, so only our stack can assume the role.
    # Data sources with a unique per-data-source external ID can't assume it.
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [local.stack.id]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "grafana-cloud"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cloudwatch_readonly_access" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "amazon_prometheus_query_access" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusQueryAccess"
}

resource "aws_iam_role_policy_attachment" "xray_readonly_access" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "additional_policies" {
  for_each = var.additional_policies

  role       = aws_iam_role.this.name
  policy_arn = each.value
}
