variable "stack" {
  type        = string
  description = "Observability Platform Grafana Cloud stack trusted to assume the role and that the PDC agent connects to: 'development' or 'production'"
}

variable "observability_platform_account_id" {
  type        = string
  description = "Account ID of the Observability Platform environment, which holds the PDC agent's token"
}

variable "additional_policies" {
  type        = map(string)
  description = "ARNs of any policies to attach to the Grafana Cloud role"
  default     = {}
}

variable "pdc_agent" {
  type = object({
    enabled          = bool
    token_secret_arn = string
    subnet_ids       = list(string)
    allowed_targets = list(object({
      cidr_block = string
      port       = number
    }))
    desired_count      = number
    cpu                = number
    memory             = number
    image              = string
    extra_args         = list(string)
    log_retention_days = number
    alarm_actions      = list(string)
    egress_cidr_blocks = list(string)
    privatelink        = bool
  })
  description = "Private Data Source Connect agent settings. Defaults are set by the root module"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
