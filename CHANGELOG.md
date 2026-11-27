# Changelog

## Unreleased

### Added

- `enable_amazon_managed_grafana`, defaulting to `true`, to let Grafana Cloud / PDC-only tenants skip the AMG role and its policy attachments.
- A module `moved` block preserving existing AMG resources when upgrading to the counted module. Earlier root-resource moves remain supported.

### Changed

- `amazon_managed_grafana_role_arn` returns `null` when AMG is disabled. Disabling AMG on an existing tenant plans removal of its AMG resources; Grafana Cloud and PDC remain unchanged.
