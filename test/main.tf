/* Based on https://docs.localstack.cloud/user-guide/integrations/terraform/#final-configuration */
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

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

module "observability_platform_tenant" {
  source = "../"

  observability_platform_account_id = "111111111111"
  enable_xray                       = true
}
