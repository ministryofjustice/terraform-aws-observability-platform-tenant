# Amazon Managed Grafana

variable "role_name" {
  type        = string
  description = "Name of the Amazon Managed Grafana role to create. This is set as a variable but Observability Platform requires this to be set to 'observability-platform'"
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
  description = "Enable AWS Managed Prometheus' query access managed policy on the Amazon Managed Grafana role"
  default     = false
}

variable "enable_xray" {
  type        = bool
  description = "Enable AWS X-Ray's read only managed policy on the Amazon Managed Grafana role"
  default     = false
}

variable "additional_policies" {
  type        = map(string)
  description = "ARNs of any policies to attach to the Amazon Managed Grafana role"
  default     = {}
}

# Grafana Cloud

variable "grafana_cloud" {
  type = object({
    stack_id            = string
    aws_account_id      = optional(string, "008923505280")
    additional_policies = optional(map(string), {})
    features = optional(object({
      cloudwatch = optional(bool, true)
      prometheus = optional(bool, false)
      xray       = optional(bool, false)
      pdc_agent  = optional(bool, false)
    }), {})
    pdc_agent = optional(object({
      cluster_name       = string
      token_secret_arn   = string
      token_kms_key_arn  = string
      vpc_id             = string
      subnet_ids         = list(string)
      desired_count      = optional(number, 2)
      cpu                = optional(number, 256)
      memory             = optional(number, 512)
      image              = optional(string, "docker.io/grafana/pdc-agent:0.0.67")
      extra_args         = optional(list(string), [])
      log_retention_days = optional(number, 365)
      alarm_actions      = optional(list(string), [])
      egress_cidr_blocks = optional(list(string), ["0.0.0.0/0"])
    }))
  })
  description = <<-EOT
    Enables Grafana Cloud connectivity. Leave as null to deploy only the Amazon Managed Grafana role.

    - stack_id: the Grafana Cloud stack ID, used as the external ID on the role and as the PDC hosted Grafana ID.
    - aws_account_id: Grafana Cloud's AWS account that is trusted to assume the role.
    - features: which capabilities to enable. 'pdc_agent' requires 'pdc_agent' settings.
    - pdc_agent: where and how to run the Private Data Source Connect agent. The token secret and KMS key live in the Observability Platform account.
  EOT
  default     = null

  validation {
    condition     = var.grafana_cloud == null ? true : can(regex("^[0-9]+$", var.grafana_cloud.stack_id))
    error_message = "grafana_cloud.stack_id must be the numeric Grafana Cloud stack ID"
  }
  validation {
    condition     = var.grafana_cloud == null ? true : (var.grafana_cloud.features.pdc_agent == (var.grafana_cloud.pdc_agent != null))
    error_message = "Set grafana_cloud.pdc_agent if, and only if, grafana_cloud.features.pdc_agent is true"
  }
  validation {
    condition     = var.grafana_cloud == null ? true : (var.grafana_cloud.pdc_agent == null ? true : var.grafana_cloud.pdc_agent.desired_count >= 2)
    error_message = "grafana_cloud.pdc_agent.desired_count must be at least 2 so rolling restarts do not drop connectivity"
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
