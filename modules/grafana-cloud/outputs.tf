output "role_arn" {
  description = "ARN of the Grafana Cloud role"
  value       = aws_iam_role.this.arn
}

output "pdc_agent_execution_role_arn" {
  description = "ARN of the PDC agent execution role, or null if the PDC agent is not enabled"
  value       = one(aws_iam_role.pdc_agent_execution[*].arn)
}

output "pdc_agent_restarter_role_arn" {
  description = "ARN of the PDC agent restarter role, or null if the PDC agent is not enabled"
  value       = one(aws_iam_role.pdc_agent_restarter[*].arn)
}

output "pdc_agent_security_group_id" {
  description = "ID of the PDC agent security group, or null if the PDC agent is not enabled"
  value       = one(aws_security_group.pdc_agent[*].id)
}
