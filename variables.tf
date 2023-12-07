variable "role_name" {
  type        = string
  description = "Name of the role to create, This is set as a variable but Observability Platform requires this to be set to 'observability-platform'"
  default     = "observability-platform"
}

variable "observability_platform_account_id" {
  type        = string
  description = "Account ID of the Observability Platform environment. If you are running on Modernisation Platform you can use 'local.environment_management.account_ids[\"observability-platform-production\"]"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to resources"
}
