output "role_arn" {
  description = "ARN of the Amazon Managed Grafana role"
  value       = aws_iam_role.this.arn
}
