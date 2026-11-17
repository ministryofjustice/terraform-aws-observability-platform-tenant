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

  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "111111111111"
    }
  }
}

variables {
  stack                             = "development"
  observability_platform_account_id = "222222222222"
  pdc_agent = {
    enabled            = true
    token_secret_arn   = null
    subnet_ids         = null
    allowed_targets    = []
    desired_count      = 3
    cpu                = 256
    memory             = 512
    image              = "docker.io/grafana/pdc-agent:latest"
    extra_args         = ["-log.level", "debug"]
    log_retention_days = 365
    alarm_actions      = []
    egress_cidr_blocks = ["0.0.0.0/0"]
  }
}

run "pdc_agent_development_stack" {
  command = apply

  module {
    source = "./modules/grafana-cloud"
  }

  assert {
    condition     = one(one(data.aws_iam_policy_document.assume.statement[0].condition).values) == "1907843"
    error_message = "The Grafana Cloud role should only trust the development stack"
  }

  assert {
    condition = jsondecode(aws_ecs_task_definition.pdc_agent[0].container_definitions)[0].command == [
      "-cluster", "prod-gb-south-1", "-gcloud-hosted-grafana-id", "1907843", "-log.level", "debug",
    ]
    error_message = "The PDC agent should connect to the development stack, with the extra arguments"
  }

  assert {
    condition     = aws_ecs_service.pdc_agent[0].network_configuration[0].subnets == toset(["subnet-0aaaaaaaaaaaaaaaa", "subnet-0bbbbbbbbbbbbbbbb", "subnet-0cccccccccccccccc"])
    error_message = "The PDC agent should run in the Modernisation Platform general private subnets by default"
  }

  assert {
    condition     = aws_security_group.pdc_agent[0].vpc_id == "vpc-0123456789abcdef0"
    error_message = "The PDC agent security group should be in the subnets' VPC"
  }

  assert {
    condition = (
      jsondecode(aws_ecs_task_definition.pdc_agent[0].container_definitions)[0].secrets[0].valueFrom == "arn:aws:secretsmanager:eu-west-2:222222222222:secret:grafana-cloud/pdc/111111111111" &&
      jsondecode(aws_iam_role_policy.pdc_agent_token[0].policy).Statement[0].Resource == [
        "arn:aws:secretsmanager:eu-west-2:222222222222:secret:grafana-cloud/pdc/111111111111",
        "arn:aws:secretsmanager:eu-west-2:222222222222:secret:grafana-cloud/pdc/111111111111-??????",
      ]
    )
    error_message = "The PDC agent should read the token from the secret Observability Platform creates for the account, whatever its suffix"
  }

  assert {
    condition = (
      jsondecode(aws_iam_role_policy.pdc_agent_token[0].policy).Statement[1].Resource == ["arn:aws:kms:eu-west-2:222222222222:key/*"] &&
      jsondecode(aws_iam_role_policy.pdc_agent_token[0].policy).Statement[1].Condition.StringEquals["kms:ViaService"] == "secretsmanager.eu-west-2.amazonaws.com"
    )
    error_message = "The PDC agent should only decrypt the token through Secrets Manager, with keys in the secret's account and region"
  }
}

run "pdc_agent_token_secret_override" {
  command = apply

  module {
    source = "./modules/grafana-cloud"
  }

  variables {
    pdc_agent = merge(var.pdc_agent, {
      token_secret_arn = "arn:aws:secretsmanager:eu-west-1:333333333333:secret:example-AbCdEf"
    })
  }

  assert {
    condition = (
      jsondecode(aws_ecs_task_definition.pdc_agent[0].container_definitions)[0].secrets[0].valueFrom == "arn:aws:secretsmanager:eu-west-1:333333333333:secret:example-AbCdEf" &&
      jsondecode(aws_iam_role_policy.pdc_agent_token[0].policy).Statement[0].Resource[0] == "arn:aws:secretsmanager:eu-west-1:333333333333:secret:example-AbCdEf" &&
      jsondecode(aws_iam_role_policy.pdc_agent_token[0].policy).Statement[1].Resource == ["arn:aws:kms:eu-west-1:333333333333:key/*"] &&
      jsondecode(aws_iam_role_policy.pdc_agent_token[0].policy).Statement[1].Condition.StringEquals["kms:ViaService"] == "secretsmanager.eu-west-1.amazonaws.com"
    )
    error_message = "The PDC agent should read the given token secret, and decrypt it with keys in that secret's account and region"
  }
}

run "pdc_agent_subnets_and_targets" {
  command = apply

  module {
    source = "./modules/grafana-cloud"
  }

  variables {
    pdc_agent = merge(var.pdc_agent, {
      subnet_ids = ["subnet-0dddddddddddddddd", "subnet-0eeeeeeeeeeeeeeee"]
      allowed_targets = [
        { cidr_block = "10.0.0.0/16", port = 5432 },
        { cidr_block = "0.0.0.0/0", port = 443 },
      ]
    })
  }

  assert {
    condition     = length(data.aws_subnets.pdc_agent) == 0 && aws_ecs_service.pdc_agent[0].network_configuration[0].subnets == toset(["subnet-0dddddddddddddddd", "subnet-0eeeeeeeeeeeeeeee"])
    error_message = "The PDC agent should run in the given subnets, without looking any up"
  }

  assert {
    condition     = toset(keys(aws_vpc_security_group_egress_rule.pdc_agent)) == toset(["0.0.0.0/0-22", "0.0.0.0/0-443", "10.0.0.0/16-5432"])
    error_message = "The PDC agent should reach Grafana Cloud, AWS APIs and the allowed targets, without duplicate rules"
  }
}

run "pdc_agent_without_general_private_subnets" {
  command = plan

  module {
    source = "./modules/grafana-cloud"
  }

  override_data {
    target = data.aws_subnets.pdc_agent
    values = {
      ids = []
    }
  }

  expect_failures = [data.aws_subnets.pdc_agent]
}

run "pdc_agent_general_private_subnets_in_several_vpcs" {
  command = plan

  module {
    source = "./modules/grafana-cloud"
  }

  override_data {
    target = data.aws_subnets.pdc_agent_vpc
    values = {
      ids = ["subnet-0aaaaaaaaaaaaaaaa"]
    }
  }

  expect_failures = [data.aws_subnets.pdc_agent_vpc]
}

run "production_stack_without_pdc_agent" {
  command = plan

  module {
    source = "./modules/grafana-cloud"
  }

  variables {
    stack     = "production"
    pdc_agent = merge(var.pdc_agent, { enabled = false, token_secret_arn = null })
  }

  assert {
    condition     = one(one(data.aws_iam_policy_document.assume.statement[0].condition).values) == "1907875"
    error_message = "The Grafana Cloud role should only trust the production stack"
  }

  assert {
    condition     = length(data.aws_subnets.pdc_agent) == 0 && length(aws_ecs_service.pdc_agent) == 0 && length(aws_vpc_security_group_egress_rule.pdc_agent) == 0
    error_message = "No PDC agent resources should be created when the PDC agent is disabled"
  }
}
