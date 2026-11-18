locals {
  # Grafana Cloud's AWS account, which assumes roles on behalf of every Grafana Cloud stack
  grafana_cloud_aws_account_id = "008923505280"

  # Observability Platform's stacks, managed in modernisation-platform-environments (observability-platform/grafana-cloud-stack.tf),
  # with the Grafana Cloud cluster and AWS region that host each one
  stacks = {
    development = {
      id         = "1907843"
      cluster    = "prod-gb-south-1"
      aws_region = "eu-west-2"
    }
    production = {
      id         = "1907875"
      cluster    = "prod-gb-south-1"
      aws_region = "eu-west-2"
    }
  }

  stack = local.stacks[var.stack]

  # Observability Platform's region, where it keeps each account's PDC agent token
  observability_platform_region = "eu-west-2"
}
