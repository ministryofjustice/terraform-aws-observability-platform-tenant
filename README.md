# Observability Platform Tenant Terraform Module

[![repo standards badge](https://img.shields.io/endpoint?labelColor=231f20&color=005ea5&style=for-the-badge&label=MoJ%20Compliant&url=https%3A%2F%2Foperations-engineering-reports.cloud-platform.service.justice.gov.uk%2Fapi%2Fv1%2Fcompliant_public_repositories%2Fendpoint%2Ftemplate-repository&logo=data:image/png;base64,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)](https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/public-report/terraform-aws-observability-platform-tenant)

This Terraform module provisions the resources [Observability Platform](https://github.com/ministryofjustice/observability-platform) needs to read from a tenant account, with Amazon Managed Grafana (AMG) and Grafana Cloud.

| Submodule | Creates |
| --- | --- |
| `modules/amazon-managed-grafana` | The `observability-platform` role that Amazon Managed Grafana assumes |
| `modules/grafana-cloud` | The `grafana-cloud` role that Grafana Cloud assumes to read CloudWatch, X-Ray and Amazon Managed Service for Prometheus, and optionally a [Private Data Source Connect (PDC)](https://grafana.com/docs/grafana-cloud/observe-and-act/connect-externally-hosted/private-data-source-connect/) agent on ECS Fargate |

Both roles are created by default. The PDC agent is only needed to query data sources inside a VPC.

Grafana Cloud data sources assume the `grafana-cloud` role with [Grafana Assume Role](https://grafana.com/docs/grafana/latest/datasources/aws-cloudwatch/aws-authentication/#use-grafana-assume-role), using the stack's shared external ID. Data sources with a unique per-data-source external ID can't assume it.

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

### Querying data sources inside a VPC

To query data sources that are only reachable inside your VPC, such as OpenSearch or a database, run the PDC agent:

1. Set `pdc_enabled = true` for the account in the Grafana Cloud tenant configuration. Observability Platform creates a PDC token secret that the agent can read, and gives you its ARN.
1. Enable the agent with the token secret's ARN, and the data sources it may connect to:

   ```hcl
   module "observability_platform_tenant" {
     source  = "ministryofjustice/observability-platform-tenant/aws"
     version = "X.X.X"

     observability_platform_account_id = local.environment_management.account_ids["observability-platform-production"]

     grafana_cloud = {
       pdc_agent = {
         enabled          = true
         token_secret_arn = "arn:aws:secretsmanager:eu-west-2:<observability platform account ID>:secret:grafana-cloud/pdc/<tenant>-<suffix>"
         allowed_targets = [
           { cidr_block = "10.26.0.0/21", port = 443 },
         ]
       }
     }

     tags = local.tags
   }
   ```

1. Allow the agent's security group, output as `grafana_cloud_pdc_agent_security_group_id`, into each data source's security group.

By default the agent runs three tasks in the Modernisation Platform `general-private` subnets. Outside Modernisation Platform, set `subnet_ids`.

The agent connects out to Grafana Cloud's PDC API on port 443 and PDC gateway on port 22, and to Docker Hub, Secrets Manager and CloudWatch Logs on port 443.
Its subnets need a NAT gateway, or PrivateLink and VPC endpoints for those services. To limit where it can connect, set `egress_cidr_blocks`.
Docker Hub may rate limit anonymous image pulls. To avoid this, set `image` to a copy in ECR, for example through a pull through cache.

The agent runs as a non-root user with all Linux capabilities dropped. Its root filesystem is writable, because it writes SSH keys to its home directory when it starts, and Fargate volumes are not writable by non-root users.

Its execution role is named `grafana-pdc-agent-execution`, which the token secret and key policies in Observability Platform trust, so each account can run one agent.

## Inputs

| Name | Description | Default |
| --- | --- | --- |
| `observability_platform_account_id` | Account ID of the Observability Platform environment that Amazon Managed Grafana runs in | Required |
| `role_name` | Name of the Amazon Managed Grafana role, which must be `observability-platform` | `"observability-platform"` |
| `enable_prometheus` | Attach AmazonPrometheusQueryAccess to the Amazon Managed Grafana role | `false` |
| `enable_xray` | Attach AWSXrayReadOnlyAccess to the Amazon Managed Grafana role | `false` |
| `additional_policies` | ARNs of policies to attach to both roles | `{}` |
| `grafana_cloud` | Grafana Cloud settings, below | `{}` |
| `tags` | Tags to apply to resources | `{}` |

| `grafana_cloud` attribute | Description | Default |
| --- | --- | --- |
| `enabled` | Create the `grafana-cloud` role | `true` |
| `stack` | Observability Platform stack trusted to assume the role, and that the PDC agent connects to: `development` or `production` | `"production"` |
| `additional_policies` | ARNs of policies to attach to the `grafana-cloud` role only | `{}` |
| `pdc_agent.enabled` | Run the PDC agent | `false` |
| `pdc_agent.token_secret_arn` | ARN of the agent's token secret in Observability Platform. Required when the agent is enabled | |
| `pdc_agent.subnet_ids` | Private subnets to run the agent in | Modernisation Platform `general-private` subnets |
| `pdc_agent.allowed_targets` | CIDR blocks and TCP ports of data sources the agent may connect to | `[]` |
| `pdc_agent.desired_count` | Number of agent tasks, at least 2 | `3` |
| `pdc_agent.cpu`, `pdc_agent.memory` | Task CPU units and memory in MiB | `256`, `512` |
| `pdc_agent.image` | Agent image | `grafana/pdc-agent` 0.0.69, pinned by digest |
| `pdc_agent.extra_args` | Extra arguments for the agent | `[]` |
| `pdc_agent.log_retention_days` | Days to keep the agent's logs | `365` |
| `pdc_agent.alarm_actions` | ARNs to notify when fewer agent tasks are running than desired | `[]` |
| `pdc_agent.egress_cidr_blocks` | CIDR blocks the agent may reach on ports 22 and 443, for Grafana Cloud and AWS APIs | `["0.0.0.0/0"]` |

## Outputs

| Name | Description |
| --- | --- |
| `amazon_managed_grafana_role_arn` | ARN of the Amazon Managed Grafana role |
| `grafana_cloud_role_arn` | ARN of the Grafana Cloud role, or null if it is not enabled |
| `grafana_cloud_pdc_agent_execution_role_arn` | ARN of the PDC agent execution role, or null if the agent is not enabled |
| `grafana_cloud_pdc_agent_security_group_id` | ID of the PDC agent security group, or null if the agent is not enabled |

## Upgrading from 2.0.0

- The Amazon Managed Grafana role moves into `module.amazon_managed_grafana` with `moved` blocks, so it is not recreated.
- The `grafana-cloud` role is created by default. If the account already has a role with that name, import it, or set `grafana_cloud = { enabled = false }`.
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

### Contributing

The base branch requires _all_ commits to be signed. Learn more about [signing commits](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification).
