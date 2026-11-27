mock_provider "aws" {
  override_during = plan

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "111111111111"
    }
  }

  mock_data "aws_region" {
    defaults = {
      region = "eu-west-2"
    }
  }

  mock_data "aws_subnet" {
    defaults = {
      vpc_id = "vpc-0123456789abcdef0"
    }
  }

  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::111111111111:role/mock"
      id  = "mock"
    }
  }

  mock_resource "aws_security_group" {
    defaults = {
      id = "sg-0123456789abcdef0"
    }
  }

  mock_resource "aws_ecs_cluster" {
    defaults = {
      id  = "arn:aws:ecs:eu-west-2:111111111111:cluster/grafana-pdc-agent"
      arn = "arn:aws:ecs:eu-west-2:111111111111:cluster/grafana-pdc-agent"
    }
  }

  mock_resource "aws_ecs_task_definition" {
    defaults = {
      arn = "arn:aws:ecs:eu-west-2:111111111111:task-definition/grafana-pdc-agent:1"
    }
  }

  mock_resource "aws_ecs_service" {
    defaults = {
      arn = "arn:aws:ecs:eu-west-2:111111111111:service/grafana-pdc-agent/grafana-pdc-agent"
    }
  }
}

variables {
  observability_platform_account_id = "222222222222"
}

run "amazon_managed_grafana_by_default" {
  command = plan

  assert {
    condition     = length(module.amazon_managed_grafana) == 1 && output.amazon_managed_grafana_role_arn == module.amazon_managed_grafana[0].role_arn
    error_message = "AMG must remain enabled by default and export the counted module's role ARN"
  }

  assert {
    condition     = output.amazon_managed_grafana_role_arn != null && output.grafana_cloud_role_arn != null && output.grafana_cloud_pdc_agent_execution_role_arn == null
    error_message = "Both roles must remain enabled by default, with PDC opt-in"
  }
}

run "pdc_with_amazon_managed_grafana" {
  command = plan

  variables {
    enable_prometheus = true
    enable_xray       = true
    additional_policies = {
      athena = "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
    }
    grafana_cloud = {
      pdc_agent = {
        enabled    = true
        subnet_ids = ["subnet-0aaaaaaaaaaaaaaaa", "subnet-0bbbbbbbbbbbbbbbb"]
        allowed_targets = [
          { cidr_block = "10.0.0.0/16", port = 443 },
        ]
      }
    }
  }

  assert {
    condition = (
      output.amazon_managed_grafana_role_arn != null &&
      output.grafana_cloud_pdc_agent_execution_role_arn != null &&
      output.grafana_cloud_pdc_agent_restarter_role_arn != null &&
      output.grafana_cloud_pdc_agent_security_group_id != null
    )
    error_message = "AMG and PDC must both be available when PDC is enabled"
  }
}

run "pdc_without_amazon_managed_grafana" {
  command = plan

  variables {
    enable_amazon_managed_grafana = false
    enable_prometheus             = true
    enable_xray                   = true
    additional_policies = {
      athena = "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
    }
    grafana_cloud = {
      pdc_agent = {
        enabled    = true
        subnet_ids = ["subnet-0aaaaaaaaaaaaaaaa", "subnet-0bbbbbbbbbbbbbbbb"]
        allowed_targets = [
          { cidr_block = "10.0.0.0/16", port = 443 },
        ]
      }
    }
  }

  assert {
    condition     = length(module.amazon_managed_grafana) == 0 && output.amazon_managed_grafana_role_arn == null
    error_message = "Disabling AMG must remove its entire module, even when optional AMG policies are enabled, and return a null ARN"
  }

  assert {
    condition = (
      length(module.grafana_cloud) == 1 &&
      output.grafana_cloud_role_arn == run.pdc_with_amazon_managed_grafana.grafana_cloud_role_arn &&
      output.grafana_cloud_pdc_agent_execution_role_arn == run.pdc_with_amazon_managed_grafana.grafana_cloud_pdc_agent_execution_role_arn &&
      output.grafana_cloud_pdc_agent_restarter_role_arn == run.pdc_with_amazon_managed_grafana.grafana_cloud_pdc_agent_restarter_role_arn &&
      output.grafana_cloud_pdc_agent_security_group_id == run.pdc_with_amazon_managed_grafana.grafana_cloud_pdc_agent_security_group_id
    )
    error_message = "Disabling AMG must leave the Grafana Cloud role and PDC outputs unchanged"
  }
}

run "both_grafana_integrations_disabled" {
  command = plan

  variables {
    enable_amazon_managed_grafana = false
    grafana_cloud = {
      enabled = false
    }
  }

  assert {
    condition = (
      length(module.amazon_managed_grafana) == 0 &&
      length(module.grafana_cloud) == 0 &&
      output.amazon_managed_grafana_role_arn == null &&
      output.grafana_cloud_role_arn == null &&
      output.grafana_cloud_pdc_agent_execution_role_arn == null &&
      output.grafana_cloud_pdc_agent_restarter_role_arn == null &&
      output.grafana_cloud_pdc_agent_security_group_id == null
    )
    error_message = "Both integrations must be independently disableable with null outputs"
  }
}
