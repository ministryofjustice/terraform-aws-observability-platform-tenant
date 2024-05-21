variable "role_name" {
  type        = string
  description = "Name of the role to create, This is set as a variable but Observability Platform requires this to be set to 'observability-platform'"
  default     = "observability-platform"
  validation {
    condition     = var.role_name == "observability-platform"
    error_message = "Role name must be set to 'observability-platform'"
  }
}

variable "observability_platform_account_id" {
  type        = string
  description = "Account ID of the Observability Platform environment. If you are running on Modernisation Platform you can use 'local.environment_management.account_ids[\"observability-platform-production\"]'"
  validation {
    condition     = length(var.observability_platform_account_id) == 12
    error_message = "Account ID must be a 12-digit number (https://docs.aws.amazon.com/accounts/latest/reference/manage-acct-identifiers.html)"
  }
}

variable "enable_prometheus" {
  type        = bool
  description = "Enable AWS Managed Prometheus' query access managed policy"
  default     = false
}

variable "enable_xray" {
  type        = bool
  description = "Enable AWS X-Ray's read only managed policy"
  default     = false
}

variable "additional_policies" {
  type        = map(string)
  description = "ARNs of any policies to attach to the IAM role"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
