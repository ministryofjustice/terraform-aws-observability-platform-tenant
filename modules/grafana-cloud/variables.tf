variable "stack_id" {
  type        = string
  description = "Grafana Cloud stack ID. Used as the external ID on the role and as the PDC hosted Grafana ID"
}

variable "aws_account_id" {
  type        = string
  description = "Grafana Cloud's AWS account, trusted to assume the role"
}

variable "features" {
  type = object({
    cloudwatch = bool
    prometheus = bool
    xray       = bool
    pdc_agent  = bool
  })
  description = "Capabilities to enable"
}

variable "additional_policies" {
  type        = map(string)
  description = "ARNs of any policies to attach to the Grafana Cloud role"
  default     = {}
}

variable "pdc_agent" {
  type = object({
    cluster_name       = string
    token_secret_arn   = string
    token_kms_key_arn  = string
    vpc_id             = string
    subnet_ids         = list(string)
    desired_count      = number
    cpu                = number
    memory             = number
    image              = string
    extra_args         = list(string)
    log_retention_days = number
    alarm_actions      = list(string)
    egress_cidr_blocks = list(string)
  })
  description = "Private Data Source Connect agent settings. Required when features.pdc_agent is true"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
