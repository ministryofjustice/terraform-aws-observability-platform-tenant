# Amazon Managed Grafana

variable "enable_amazon_managed_grafana" {
  type        = bool
  description = "Create the Amazon Managed Grafana role and its policy attachments. Disable for tenants that only use Grafana Cloud"
  default     = true
}

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
  description = "ARNs of policies to attach to both enabled roles, so data sources keep working when they move from Amazon Managed Grafana to Grafana Cloud"
  default     = {}
}

# Grafana Cloud

variable "grafana_cloud" {
  type = object({
    enabled             = optional(bool, true)
    stack               = optional(string, "production")
    additional_policies = optional(map(string), {})
    pdc_agent = optional(object({
      enabled          = optional(bool, false)
      token_secret_arn = optional(string)
      subnet_ids       = optional(list(string))
      allowed_targets = optional(list(object({
        cidr_block = string
        port       = number
      })), [])
      desired_count = optional(number, 3)
      cpu           = optional(number, 256)
      memory        = optional(number, 512)
      # grafana/pdc-agent 0.0.69
      image              = optional(string, "docker.io/grafana/pdc-agent@sha256:32332a5d4605598d091ecaec7f977c2aecf3bdb89fb424328b3062f6c5d40561")
      extra_args         = optional(list(string), [])
      log_retention_days = optional(number, 365)
      alarm_actions      = optional(list(string), [])
      egress_cidr_blocks = optional(list(string), ["0.0.0.0/0"])
      privatelink        = optional(bool, true)
    }), {})
  })
  description = <<-EOT
    Grafana Cloud settings. The defaults create the 'grafana-cloud' role for the production stack. The PDC agent is opt-in.

    - enabled: create the 'grafana-cloud' role that Grafana Cloud assumes to read CloudWatch, X-Ray and Amazon Managed Service for Prometheus, and the PDC agent if it's enabled.
    - stack: the Observability Platform stack trusted to assume the role, 'development' or 'production'.
    - additional_policies: ARNs of policies to attach to the 'grafana-cloud' role only.
    - pdc_agent: a Private Data Source Connect agent, so Grafana Cloud can query data sources inside the VPC.
      - enabled: run the agent on ECS Fargate. Must match the account's pdc_enabled setting in Observability Platform's Grafana Cloud tenant configuration.
      - token_secret_arn: full ARN of the agent's token secret. Defaults to the secret Observability Platform creates for this account, grafana-cloud/pdc/<account ID>.
      - subnet_ids: subnets to run the agent in. Defaults to the Modernisation Platform general private subnets.
      - allowed_targets: CIDR blocks and TCP ports of the data sources the agent may connect to.
      - desired_count: number of agent tasks, at least 2.
      - egress_cidr_blocks: CIDR blocks the agent may reach on ports 22 and 443, for Grafana Cloud and AWS APIs.
      - privatelink: connect to Grafana Cloud through its PDC PrivateLink endpoints in the agent's VPC. Set to false to connect over the internet, which needs outbound port 22.
  EOT
  default     = {}
  nullable    = false

  validation {
    condition     = contains(["development", "production"], var.grafana_cloud.stack)
    error_message = "grafana_cloud.stack must be 'development' or 'production'"
  }
  validation {
    condition     = var.grafana_cloud.pdc_agent.token_secret_arn == null || can(regex("^arn:aws:secretsmanager:[a-z0-9-]+:[0-9]{12}:secret:.+$", var.grafana_cloud.pdc_agent.token_secret_arn))
    error_message = "grafana_cloud.pdc_agent.token_secret_arn must be the ARN of a Secrets Manager secret"
  }
  validation {
    condition     = var.grafana_cloud.pdc_agent.desired_count >= 2
    error_message = "grafana_cloud.pdc_agent.desired_count must be at least 2 so the agent stays connected while a task is replaced"
  }
  validation {
    condition     = var.grafana_cloud.pdc_agent.subnet_ids == null ? true : length(var.grafana_cloud.pdc_agent.subnet_ids) > 0
    error_message = "grafana_cloud.pdc_agent.subnet_ids must not be empty. Leave it unset to use the Modernisation Platform general private subnets"
  }
  validation {
    condition = alltrue([
      for target in var.grafana_cloud.pdc_agent.allowed_targets :
      can(cidrnetmask(target.cidr_block)) && target.port >= 1 && target.port <= 65535 && floor(target.port) == target.port
    ])
    error_message = "Each grafana_cloud.pdc_agent.allowed_targets entry needs an IPv4 CIDR block and a TCP port from 1 to 65535"
  }
  validation {
    condition     = alltrue([for cidr_block in var.grafana_cloud.pdc_agent.egress_cidr_blocks : can(cidrnetmask(cidr_block))])
    error_message = "grafana_cloud.pdc_agent.egress_cidr_blocks must be IPv4 CIDR blocks"
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
