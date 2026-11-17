mock_provider "aws" {
  # The AWS provider validates these values, so they must look real
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::111111111111:role/mock"
    }
  }

  mock_data "aws_subnets" {
    defaults = {
      ids = ["subnet-0aaaaaaaaaaaaaaaa", "subnet-0bbbbbbbbbbbbbbbb", "subnet-0cccccccccccccccc"]
    }
  }

  mock_data "aws_subnet" {
    defaults = {
      vpc_id = "vpc-0123456789abcdef0"
    }
  }
}

variables {
  observability_platform_account_id = "111111111111"
}

run "grafana_cloud_by_default" {
  command = apply

  assert {
    condition     = output.grafana_cloud_role_arn != null
    error_message = "The Grafana Cloud role should be created by default"
  }

  assert {
    condition     = output.grafana_cloud_pdc_agent_execution_role_arn == null && output.grafana_cloud_pdc_agent_security_group_id == null
    error_message = "The PDC agent should not be created by default"
  }
}

run "grafana_cloud_disabled" {
  command = plan

  variables {
    grafana_cloud = {
      enabled = false
    }
  }

  assert {
    condition     = length(module.grafana_cloud) == 0
    error_message = "No Grafana Cloud resources, including the PDC agent, should be created when grafana_cloud.enabled is false"
  }
}

run "pdc_agent_enabled" {
  command = apply

  variables {
    grafana_cloud = {
      pdc_agent = {
        enabled = true
      }
    }
  }

  assert {
    condition     = output.grafana_cloud_pdc_agent_execution_role_arn != null && output.grafana_cloud_pdc_agent_security_group_id != null
    error_message = "The PDC agent should be created when grafana_cloud.pdc_agent.enabled is true"
  }
}

run "invalid_stack" {
  command = plan

  variables {
    grafana_cloud = {
      stack = "staging"
    }
  }

  expect_failures = [var.grafana_cloud]
}

run "pdc_agent_invalid_token_secret_arn" {
  command = plan

  variables {
    grafana_cloud = {
      pdc_agent = {
        token_secret_arn = "grafana-cloud/pdc/111111111111"
      }
    }
  }

  expect_failures = [var.grafana_cloud]
}

run "pdc_agent_needs_two_tasks" {
  command = plan

  variables {
    grafana_cloud = {
      pdc_agent = {
        desired_count = 1
      }
    }
  }

  expect_failures = [var.grafana_cloud]
}

run "pdc_agent_invalid_allowed_target" {
  command = plan

  variables {
    grafana_cloud = {
      pdc_agent = {
        allowed_targets = [{ cidr_block = "10.0.0.0/16", port = 0 }]
      }
    }
  }

  expect_failures = [var.grafana_cloud]
}
