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
    sts = "http://127.0.0.1:4566"
  }
}

run "main" {
  command = apply
}

run "attach_amazon_prometheus_query_access" {
  command = plan

  variables {
    enable_amazon_prometheus_query_access = true
  }
}

run "additional_policies" {
  command = plan

  variables {
    additional_policies = {
      AmazonDevOpsGuruReadOnlyAccess = "arn:aws:iam::aws:policy/AmazonDevOpsGuruReadOnlyAccess"
    }
  }
}
