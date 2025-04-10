# Analytical Platform Observability Terraform Module

[![Ministry of Justice Repository Compliance Badge](https://github-community.service.justice.gov.uk/repository-standards/api/terraform-aws-analytical-platform-observability/badge)](https://github-community.service.justice.gov.uk/repository-standards/terraform-aws-analytical-platform-observability)

[![Open in Dev Container](https://raw.githubusercontent.com/ministryofjustice/.devcontainer/refs/heads/main/contrib/badge.svg)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/ministryofjustice/terraform-aws-analytical-platform-observability)

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/ministryofjustice/terraform-aws-analytical-platform-observability)

This Terraform module provisions the required resources for Analytical Platform's Grafana to read CloudWatch.

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

## Testing

```bash
make test
```

### Contributing

The base branch requires _all_ commits to be signed. Learn more about signing commits [here](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification).
