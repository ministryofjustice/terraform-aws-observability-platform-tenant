output "health_signal_reader_role_arn" {
  description = "ARN of the tenant role that Observability Platform assumes to read health signal inputs."
  value       = try(aws_iam_role.health_signal_reader[0].arn, null)
}
