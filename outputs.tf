output "amazon_managed_grafana_role_arn" {
  description = "ARN of the Amazon Managed Grafana role"
  value       = module.amazon_managed_grafana.role_arn
}

output "grafana_cloud_role_arn" {
  description = "ARN of the Grafana Cloud role, or null if Grafana Cloud is not enabled"
  value       = one(module.grafana_cloud[*].role_arn)
}

output "grafana_cloud_pdc_agent_execution_role_arn" {
  description = "ARN of the PDC agent execution role, or null if the PDC agent is not enabled"
  value       = one(module.grafana_cloud[*].pdc_agent_execution_role_arn)
}
