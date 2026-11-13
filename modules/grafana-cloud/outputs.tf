output "role_arn" {
  description = "ARN of the Grafana Cloud role"
  value       = aws_iam_role.this.arn
}

output "pdc_agent_execution_role_arn" {
  description = "ARN of the PDC agent execution role, or null if the PDC agent is not enabled"
  value       = one(aws_iam_role.pdc_agent_execution[*].arn)
}
