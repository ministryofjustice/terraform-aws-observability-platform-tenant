data "aws_iam_policy_document" "health_signal_reader_assume_role" {
  count = var.enable_health_signal_reader_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.observability_platform_health_signal_assumer_arns
    }
  }
}

resource "aws_iam_role" "health_signal_reader" {
  count = var.enable_health_signal_reader_role ? 1 : 0

  name               = var.health_signal_reader_role_name
  assume_role_policy = data.aws_iam_policy_document.health_signal_reader_assume_role[0].json

  # Use your module's tagging approach; if you already have var.tags, keep this.
  # If your module tags differently, adjust accordingly.
  tags = try(var.tags, null)
}

data "aws_iam_policy_document" "health_signal_reader_policy" {
  count = var.enable_health_signal_reader_role ? 1 : 0

  statement {
    sid     = "CloudWatchReadForHealthSignals"
    effect  = "Allow"
    actions = [
      "cloudwatch:GetMetricData",
      "cloudwatch:ListMetrics"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "EC2DescribeForSubnetSignals"
    effect  = "Allow"
    actions = [
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ec2:DescribeTags"
    ]
    resources = ["*"]
  }

  # NAT gateway discovery (used by NAT error + telemetry freshness checks)
  statement {
    sid     = "EC2DescribeForNatSignals"
    effect  = "Allow"
    actions = [
      "ec2:DescribeNatGateways"
    ]
    resources = ["*"]
  }

  # Load balancer discovery (used by ALB 5xx + telemetry freshness checks)
  statement {
    sid     = "ELBv2DescribeForEdgeSignals"
    effect  = "Allow"
    actions = [
      "elasticloadbalancing:DescribeLoadBalancers"
    ]
    resources = ["*"]
  }

  # Quota + usage checks (EIP/VPC usage ratio)
  statement {
    sid     = "QuotaSignals"
    effect  = "Allow"
    actions = [
      "servicequotas:GetServiceQuota",
      "ec2:DescribeAddresses"
    ]
    resources = ["*"]
  }
}


resource "aws_iam_role_policy" "health_signal_reader" {
  count = var.enable_health_signal_reader_role ? 1 : 0

  name   = "${var.health_signal_reader_role_name}-policy"
  role   = aws_iam_role.health_signal_reader[0].id
  policy = data.aws_iam_policy_document.health_signal_reader_policy[0].json
}
