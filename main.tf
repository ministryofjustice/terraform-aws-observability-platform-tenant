module "amazon_managed_grafana" {
  source = "./modules/amazon-managed-grafana"

  role_name                         = var.role_name
  observability_platform_account_id = var.observability_platform_account_id
  enable_prometheus                 = var.enable_prometheus
  enable_xray                       = var.enable_xray
  additional_policies               = var.additional_policies
  tags                              = var.tags
}

module "grafana_cloud" {
  count  = var.grafana_cloud == null ? 0 : 1
  source = "./modules/grafana-cloud"

  stack_id            = var.grafana_cloud.stack_id
  aws_account_id      = var.grafana_cloud.aws_account_id
  features            = var.grafana_cloud.features
  additional_policies = var.grafana_cloud.additional_policies
  pdc_agent           = var.grafana_cloud.pdc_agent
  tags                = var.tags
}

# Resources moved into the Amazon Managed Grafana submodule in 3.0.0, so upgrading does not recreate the role.
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
