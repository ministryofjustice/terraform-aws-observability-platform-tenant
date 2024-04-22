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

  assert {
    condition     = aws_iam_role.this.id == "observability-platform"
    error_message = "Invalid IAM role name"
  }
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
