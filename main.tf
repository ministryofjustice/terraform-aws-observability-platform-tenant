module "amazon_managed_grafana" {
  count  = var.enable_amazon_managed_grafana ? 1 : 0
  source = "./modules/amazon-managed-grafana"

  role_name                         = var.role_name
  observability_platform_account_id = var.observability_platform_account_id
  enable_prometheus                 = var.enable_prometheus
  enable_xray                       = var.enable_xray
  additional_policies               = var.additional_policies
  tags                              = var.tags
}

module "grafana_cloud" {
  count  = var.grafana_cloud.enabled ? 1 : 0
  source = "./modules/grafana-cloud"

  stack                             = var.grafana_cloud.stack
  observability_platform_account_id = var.observability_platform_account_id
  # Shared policies give data sources the same access in Grafana Cloud as in Amazon Managed Grafana
  additional_policies = merge(var.additional_policies, var.grafana_cloud.additional_policies)
  pdc_agent           = var.grafana_cloud.pdc_agent
  tags                = var.tags
}

moved {
  from = module.amazon_managed_grafana
  to   = module.amazon_managed_grafana[0]
}

# Resources moved into the Amazon Managed Grafana submodule in 2.1.0, so upgrading does not recreate the role.
moved {
  from = aws_iam_role.this
  to   = module.amazon_managed_grafana.aws_iam_role.this
}

moved {
  from = aws_iam_role_policy_attachment.cloudwatch_readonly_access
  to   = module.amazon_managed_grafana.aws_iam_role_policy_attachment.cloudwatch_readonly_access
}

moved {
  from = aws_iam_role_policy_attachment.amazon_prometheus_query_access
  to   = module.amazon_managed_grafana.aws_iam_role_policy_attachment.amazon_prometheus_query_access
}

moved {
  from = aws_iam_role_policy_attachment.xray_readonly_access
  to   = module.amazon_managed_grafana.aws_iam_role_policy_attachment.xray_readonly_access
}

moved {
  from = aws_iam_role_policy_attachment.additional_policies
  to   = module.amazon_managed_grafana.aws_iam_role_policy_attachment.additional_policies
}
