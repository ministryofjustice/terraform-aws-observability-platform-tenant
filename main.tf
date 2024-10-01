data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.observability_platform_account_id}:root"]
    }
  }
}

data "aws_iam_policy_document" "custom_athena_policy" {
  #checkov:skip=CKV_AWS_356: Needs to access multiple resources
  #checkov:skip=CKV_AWS_111
  statement {
    sid    = "AthenaQueryAccess"
    effect = "Allow"
    actions = [
      "athena:ListDatabases",
      "athena:ListDataCatalogs",
      "athena:ListWorkGroups",
      "athena:GetDatabase",
      "athena:GetDataCatalog",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:GetTableMetadata",
      "athena:GetWorkGroup",
      "athena:ListTableMetadata",
      "athena:StartQueryExecution",
      "athena:StopQueryExecution"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "GlueReadAccess"
    effect = "Allow"
    actions = [
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:BatchGetPartition"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AthenaS3Access"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
      "s3:PutObject"
    ]
    resources = ["arn:aws:s3:::${var.grafana_athena_query_results_s3_bucket}"]
  }
  statement {
    sid       = "AthenaCostUsageReportsAccess"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.cost_usage_reports_s3_bucket}"]
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

resource "aws_iam_role_policy_attachment" "athena_custom_access" {
  count = var.enable_athena ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = data.aws_iam_policy_document.custom_athena_policy
}

resource "aws_iam_role_policy_attachment" "additional_policies" {
  for_each = { for k, v in var.additional_policies : k => v }

  role       = aws_iam_role.this.name
  policy_arn = each.value
}
