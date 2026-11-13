/* Based on https://docs.localstack.cloud/user-guide/integrations/terraform/#final-configuration */
provider "aws" {
  region     = "us-east-1"
  access_key = "mock_access_key"
  secret_key = "mock_secret_key"

  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    iam = "http://127.0.0.1:4566"
  }
}

variables {
  observability_platform_account_id = "111111111111"
}

run "main" {
  command = apply
}

run "invalid_account_id" {
  command = plan

  variables {
    observability_platform_account_id = "1234567890"
  }

  expect_failures = [var.observability_platform_account_id]
}

run "invalid_role_name" {
  command = plan

  variables {
    role_name = "bad-role-name"
  }

  expect_failures = [var.role_name]
}

run "additional_policies" {
  command = plan

  variables {
    additional_policies = {
      AmazonDevOpsGuruReadOnlyAccess = "arn:aws:iam::aws:policy/AmazonDevOpsGuruReadOnlyAccess"
    }
  }
}

run "grafana_cloud_disabled_by_default" {
  command = plan

  assert {
    condition     = length(module.grafana_cloud) == 0
    error_message = "Grafana Cloud resources should not be created unless grafana_cloud is set"
  }
}

run "grafana_cloud_cloudwatch_only" {
  command = plan

  variables {
    grafana_cloud = {
      stack_id = "1234567"
    }
  }

  assert {
    condition     = length(module.grafana_cloud) == 1
    error_message = "Grafana Cloud resources should be created when grafana_cloud is set"
  }
}

run "grafana_cloud_pdc_agent" {
  command = plan

  variables {
    grafana_cloud = {
      stack_id = "1234567"
      features = {
        pdc_agent = true
      }
      pdc_agent = {
        cluster_name      = "placeholder-pdc-network"
        token_secret_arn  = "placeholder-secret-arn"
        token_kms_key_arn = "placeholder-kms-key-arn"
        vpc_id            = "placeholder-vpc-id"
        subnet_ids        = ["placeholder-subnet-a", "placeholder-subnet-b"]
      }
    }
  }
}

run "pdc_agent_requires_settings" {
  command = plan

  variables {
    grafana_cloud = {
      stack_id = "1234567"
      features = {
        pdc_agent = true
      }
    }
  }

  expect_failures = [var.grafana_cloud]
}

run "pdc_agent_needs_two_tasks" {
  command = plan

  variables {
    grafana_cloud = {
      stack_id = "1234567"
      features = {
        pdc_agent = true
      }
      pdc_agent = {
        cluster_name      = "placeholder-pdc-network"
        token_secret_arn  = "placeholder-secret-arn"
        token_kms_key_arn = "placeholder-kms-key-arn"
        vpc_id            = "placeholder-vpc-id"
        subnet_ids        = ["placeholder-subnet-a"]
        desired_count     = 1
      }
    }
  }

  expect_failures = [var.grafana_cloud]
}
