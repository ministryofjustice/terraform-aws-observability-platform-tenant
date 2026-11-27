# Observability Platform Tenant Terraform Module

[![repo standards badge](https://img.shields.io/endpoint?labelColor=231f20&color=005ea5&style=for-the-badge&label=MoJ%20Compliant&url=https%3A%2F%2Foperations-engineering-reports.cloud-platform.service.justice.gov.uk%2Fapi%2Fv1%2Fcompliant_public_repositories%2Fendpoint%2Ftemplate-repository&logo=data:image/png;base64,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)](https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/public-report/terraform-aws-observability-platform-tenant)

This Terraform module provisions the resources [Observability Platform](https://github.com/ministryofjustice/observability-platform) needs to read from a tenant account, with Amazon Managed Grafana (AMG) and Grafana Cloud.

| Submodule | Creates |
| --- | --- |
| `modules/amazon-managed-grafana` | The `observability-platform` role that Amazon Managed Grafana assumes |
| `modules/grafana-cloud` | The `grafana-cloud` role that Grafana Cloud assumes to read CloudWatch, X-Ray and Amazon Managed Service for Prometheus, and a [Private Data Source Connect (PDC)](https://grafana.com/docs/grafana-cloud/observe-and-act/connect-externally-hosted/private-data-source-connect/) agent on ECS Fargate |

Both roles are created by default. Set `enable_amazon_managed_grafana = false` to skip the AMG role and its policy attachments without affecting Grafana Cloud. The PDC agent is opt-in: it lets Grafana Cloud query data sources inside the VPC.

Grafana Cloud data sources assume the `grafana-cloud` role with [Grafana Assume Role](https://grafana.com/docs/grafana/latest/datasources/aws-cloudwatch/aws-authentication/#use-grafana-assume-role), using the stack's shared external ID. Data sources with a unique per-data-source external ID can't assume it.

## Requirements

| Name | Version |
| --- | --- |
| Terraform | `~> 1.3` |
| `hashicorp/aws` | `~> 6.0` |

## Usage

### From Modernisation Platform Environments

```hcl
module "observability_platform_tenant" {
  source  = "ministryofjustice/observability-platform-tenant/aws"
  version = "X.X.X"

  observability_platform_account_id = local.environment_management.account_ids["observability-platform-production"]

  tags = local.tags
}
```

Then add the account to your tenant in Observability Platform's [Grafana Cloud tenant configuration](https://github.com/ministryofjustice/modernisation-platform-environments/blob/main/terraform/environments/observability-platform/grafana-cloud-tenant-environment-configurations.tf), which sets up its data sources in Grafana Cloud.

The role trusts Observability Platform's production stack. To try the development stack instead, set `grafana_cloud = { stack = "development" }`.

### Moving from Amazon Managed Grafana

Callers of 2.0.0 only need to change the version. The Amazon Managed Grafana role is unchanged, so existing dashboards keep working, and `additional_policies` are also attached to the `grafana-cloud` role, so data sources such as Athena keep the same access in Grafana Cloud:

```hcl
module "observability_platform_tenant" {
  source  = "ministryofjustice/observability-platform-tenant/aws"
  version = "X.X.X"

  observability_platform_account_id = local.environment_management.account_ids["observability-platform-production"]

  # Attached to both the Amazon Managed Grafana and Grafana Cloud roles
  additional_policies = {
    additional_athena_policy = aws_iam_policy.grafana_athena_full_access_policy.arn
  }

  tags = local.tags
}
```

### All inputs

Every input, set to its default unless marked otherwise. Only `observability_platform_account_id` is required. See [Inputs](#inputs) for descriptions.

```hcl
module "observability_platform_tenant" {
  source  = "ministryofjustice/observability-platform-tenant/aws"
  version = "X.X.X"

  # Required
  observability_platform_account_id = local.environment_management.account_ids["observability-platform-production"]

  # Amazon Managed Grafana
  enable_amazon_managed_grafana = true
  role_name                    = "observability-platform" # must be "observability-platform"
  enable_prometheus            = false
  enable_xray                  = false
  additional_policies          = {} # attached to both enabled roles, e.g. { athena = aws_iam_policy.athena.arn }

  # Grafana Cloud
  grafana_cloud = {
    enabled             = true
    stack               = "production" # or "development"
    additional_policies = {}           # attached to the grafana-cloud role only

    pdc_agent = {
      enabled          = false # opt in, with pdc_enabled = true in Observability Platform
      token_secret_arn = null  # defaults to grafana-cloud/pdc/<account ID> in Observability Platform
      subnet_ids       = null  # defaults to the Modernisation Platform general-private subnets
      allowed_targets = [      # not a default: data sources the agent may connect to
        { cidr_block = "10.26.0.0/21", port = 443 },
      ]
      desired_count      = 3 # at least 2
      cpu                = 256
      memory             = 512
      image              = "docker.io/grafana/pdc-agent@sha256:32332a5d4605598d091ecaec7f977c2aecf3bdb89fb424328b3062f6c5d40561" # 0.0.69
      extra_args         = []
      log_retention_days = 365
      alarm_actions      = [] # e.g. SNS topic ARNs
      egress_cidr_blocks = ["0.0.0.0/0"]
      privatelink        = true
    }
  }

  tags = local.tags
}
```

### Querying data sources inside a VPC

The module can run a PDC agent, so Grafana Cloud can query data sources that are only reachable inside your VPC, such as OpenSearch or a database. The agent is opt-in: only enable it if the account has private data sources to query. Set `pdc_enabled = true` for the account in the Grafana Cloud tenant configuration, and Observability Platform creates a PDC token for it, in a secret named `grafana-cloud/pdc/<account ID>` that only the agent can read.

To let the agent reach your data sources:

1. Enable the agent and set the data sources it may connect to:

   ```hcl
   module "observability_platform_tenant" {
     source  = "ministryofjustice/observability-platform-tenant/aws"
     version = "X.X.X"

     observability_platform_account_id = local.environment_management.account_ids["observability-platform-production"]

     grafana_cloud = {
       pdc_agent = {
         enabled = true
         allowed_targets = [
           { cidr_block = "10.26.0.0/21", port = 443 },
         ]
       }
     }

     tags = local.tags
   }
   ```

1. Allow the agent's security group, output as `grafana_cloud_pdc_agent_security_group_id`, into each data source's security group.

The agent reads its token from the secret in the `observability_platform_account_id` account when it starts. If the agent is deployed before the secret exists, ECS keeps retrying its tasks, at most 27 minutes apart, so the agent starts by itself once the secret exists. The agent doesn't notice when the token changes, so after Observability Platform replaces the token, restart the agent:

```bash
aws ecs update-service --cluster grafana-pdc-agent --service grafana-pdc-agent --force-new-deployment
```

By default the agent runs three tasks in the Modernisation Platform `general-private` subnets. Outside Modernisation Platform member accounts, or in accounts with more than one VPC's `general-private` subnets such as core-vpc, set `subnet_ids`, or opt out.

The agent connects to Grafana Cloud's PDC API on port 443 and PDC gateway on port 22 through Grafana Cloud's [PDC PrivateLink endpoints](https://grafana.com/docs/grafana-cloud/observe-and-act/connect-externally-hosted/private-data-source-connect/pdc-agent-aws-privatelink/) in its VPC, which Modernisation Platform manages in core-vpc. Until the endpoints exist, the agent keeps retrying, and connects once they do. Outside Modernisation Platform, create the endpoints in the agent's VPC, or set `privatelink = false` to connect over the internet, which needs outbound port 22.

The agent also connects to Docker Hub, Secrets Manager and CloudWatch Logs on port 443, so its subnets need a NAT gateway, or VPC endpoints for those services. To limit where it can connect, set `egress_cidr_blocks`.
Docker Hub may rate limit anonymous image pulls. To avoid this, set `image` to a copy in ECR, for example through a pull through cache.

The agent runs as a non-root user with all Linux capabilities dropped. Its root filesystem is writable, because it writes SSH keys to its home directory when it starts, and Fargate volumes are not writable by non-root users.

Its execution role is named `grafana-pdc-agent-execution`, which the token secret and key policies in Observability Platform trust, so each account can run one agent.

### Grafana Cloud / PDC-only tenants

Tenants that do not use Amazon Managed Grafana, such as Cloud Platform, can disable it independently of Grafana Cloud and PDC:

```hcl
module "observability_platform_tenant" {
  source  = "ministryofjustice/observability-platform-tenant/aws"
  version = "X.X.X"

  enable_amazon_managed_grafana      = false
  observability_platform_account_id = "111111111111" # replace with the Observability Platform account ID

  grafana_cloud = {
    pdc_agent = {
      enabled     = true
      subnet_ids  = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"] # replace with private subnet IDs
      privatelink = false # use the internet if Grafana Cloud PDC PrivateLink endpoints are not available
      allowed_targets = [
        { cidr_block = "10.26.0.0/21", port = 443 }, # replace with the data sources' CIDRs and ports
      ]
    }
  }
}
```

`observability_platform_account_id` remains required: PDC uses it to locate the token secret and trust the token rotator. Enable `pdc_enabled` for the account in Observability Platform and follow the [PDC networking requirements](#querying-data-sources-inside-a-vpc). The `grafana-cloud` role and shared `additional_policies` are still created; the AMG role ARN output is `null`.

## Inputs

| Name | Description | Default |
| --- | --- | --- |
| `observability_platform_account_id` | Account ID of the Observability Platform environment that Amazon Managed Grafana runs in, and that holds the PDC agent's token | Required |
| `enable_amazon_managed_grafana` | Create the Amazon Managed Grafana role and its policy attachments; independent of Grafana Cloud and PDC | `true` |
| `role_name` | Name of the Amazon Managed Grafana role, which must be `observability-platform` | `"observability-platform"` |
| `enable_prometheus` | Attach AmazonPrometheusQueryAccess to the Amazon Managed Grafana role | `false` |
| `enable_xray` | Attach AWSXrayReadOnlyAccess to the Amazon Managed Grafana role | `false` |
| `additional_policies` | ARNs of policies to attach to both enabled roles | `{}` |
| `grafana_cloud` | Grafana Cloud settings, below | `{}` |
| `tags` | Tags to apply to resources | `{}` |

| `grafana_cloud` attribute | Description | Default |
| --- | --- | --- |
| `enabled` | Create the `grafana-cloud` role, and the PDC agent if `pdc_agent.enabled` | `true` |
| `stack` | Observability Platform stack trusted to assume the role, and that the PDC agent connects to: `development` or `production` | `"production"` |
| `additional_policies` | ARNs of policies to attach to the `grafana-cloud` role only | `{}` |
| `pdc_agent.enabled` | Run the PDC agent. Must match the account's `pdc_enabled` in Observability Platform | `false` |
| `pdc_agent.token_secret_arn` | Full ARN of the agent's token secret, to use a different secret | `grafana-cloud/pdc/<account ID>` in Observability Platform |
| `pdc_agent.subnet_ids` | Private subnets to run the agent in | Modernisation Platform `general-private` subnets |
| `pdc_agent.allowed_targets` | CIDR blocks and TCP ports of data sources the agent may connect to | `[]` |
| `pdc_agent.desired_count` | Number of agent tasks, at least 2 | `3` |
| `pdc_agent.cpu`, `pdc_agent.memory` | Task CPU units and memory in MiB | `256`, `512` |
| `pdc_agent.image` | Agent image | `grafana/pdc-agent` 0.0.69, pinned by digest |
| `pdc_agent.extra_args` | Extra arguments for the agent | `[]` |
| `pdc_agent.log_retention_days` | Days to keep the agent's logs | `365` |
| `pdc_agent.alarm_actions` | ARNs to notify when fewer agent tasks are running than desired | `[]` |
| `pdc_agent.egress_cidr_blocks` | CIDR blocks the agent may reach on ports 22 and 443, for Grafana Cloud and AWS APIs | `["0.0.0.0/0"]` |
| `pdc_agent.privatelink` | Connect to Grafana Cloud through the PDC PrivateLink endpoints in the agent's VPC, or over the internet if `false` | `true` |

## Outputs

| Name | Description |
| --- | --- |
| `amazon_managed_grafana_role_arn` | ARN of the Amazon Managed Grafana role, or null if it is not enabled |
| `grafana_cloud_role_arn` | ARN of the Grafana Cloud role, or null if it is not enabled |
| `grafana_cloud_pdc_agent_execution_role_arn` | ARN of the PDC agent execution role, or null if the agent is not enabled |
| `grafana_cloud_pdc_agent_restarter_role_arn` | ARN of the PDC agent restarter role, or null if the agent is not enabled |
| `grafana_cloud_pdc_agent_security_group_id` | ID of the PDC agent security group, or null if the agent is not enabled |

## Upgrading from 3.1.0

No input changes are needed. `enable_amazon_managed_grafana` defaults to `true`. A `moved` block moves `module.amazon_managed_grafana` to `module.amazon_managed_grafana[0]`, so this toggle introduces no resource changes for existing tenants. Terraform reports the address moves, without creating, updating, destroying or replacing the AMG resources. The earlier moves from root resource addresses are retained for older consumers.

Setting the toggle to `false` on an existing tenant **plans destruction of its AMG role and policy attachments**. Only disable it once they are no longer used. For new tenants, `false` skips AMG entirely. Grafana Cloud and PDC are unaffected.

## Upgrading from 3.0.0

No input changes are needed. When PDC is enabled, the module adds `arn:aws:iam::<tenant-account-id>:role/grafana-pdc-agent-restarter` and its inline policy. The agent still reads its token from the same secret.

The only trusted caller is `arn:aws:iam::<observability-platform-account-id>:role/grafana-pdc-token-rotator` (IAM path `/`), using the account supplied in `observability_platform_account_id`. The tenant role can be created before the rotator role exists. The rotator's identity policy must also allow `sts:AssumeRole` on the tenant role.

In the region where the tenant deployed the agent, the rotator can describe the `grafana-pdc-agent` service in the `grafana-pdc-agent` cluster and call `UpdateService` with `forceNewDeployment=true`. IAM scopes `UpdateService` to that service, not to that API parameter.

## Upgrading from 2.0.0

- The Amazon Managed Grafana role moves into `module.amazon_managed_grafana` with `moved` blocks, so it is not recreated.
- The `grafana-cloud` role is created by default. If the account already has a role with that name, import it, or set `grafana_cloud = { enabled = false }`.
- The PDC agent is opt-in, with `grafana_cloud.pdc_agent.enabled`. It runs as three ECS Fargate tasks in the Modernisation Platform `general-private` subnets, and its tasks start once Observability Platform has created the account's token. When it's enabled in accounts without one VPC's `general-private` subnets, such as the Modernisation Platform core accounts and Analytical Platform, `grafana_cloud.pdc_agent.subnet_ids` must also be set, or the plan fails.
- The PDC agent connects through Grafana Cloud's PDC PrivateLink endpoints in its VPC. Outside Modernisation Platform, create the endpoints, or set `grafana_cloud.pdc_agent.privatelink` to `false` to connect over the internet.
- `additional_policies` are also attached to the `grafana-cloud` role, so data sources keep the same access in Grafana Cloud.
- Terraform 1.3 or later is required.

## Testing

```bash
make test
```

This needs Docker for LocalStack, and `tflocal` from `requirements-dev.txt`. The Grafana Cloud tests use a mocked provider, so they also run without Docker:

```bash
terraform test -filter=tests/grafana_cloud.tftest.hcl -filter=tests/grafana_cloud_pdc_agent.tftest.hcl
```

The AMG toggle tests use plan-only runs with mocked providers (Terraform 1.9 or later), requiring neither Docker nor AWS credentials:

```bash
terraform init
terraform test -filter=tests/amazon_managed_grafana.tftest.hcl
```

### Contributing

The base branch requires _all_ commits to be signed. Learn more about [signing commits](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification).
