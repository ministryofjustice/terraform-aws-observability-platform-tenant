# Private Data Source Connect (PDC) agent, run on ECS Fargate.
#
# Observability Platform keeps the signing token in a Secrets Manager secret named grafana-cloud/pdc/<this account's ID>,
# encrypted with a customer managed KMS key. Both the secret policy and key policy there only trust a role
# named "grafana-pdc-agent-execution", so that name must not change.

locals {
  pdc_agent_enabled = var.pdc_agent.enabled
  pdc_agent_name    = "grafana-pdc-agent"

  pdc_agent_subnet_ids = var.pdc_agent.subnet_ids != null ? var.pdc_agent.subnet_ids : flatten(data.aws_subnets.pdc_agent[*].ids)

  # Secrets Manager adds a random suffix to the secret's ARN, so by default this is a partial ARN without it,
  # which Secrets Manager resolves
  pdc_agent_token_secret_arn = local.pdc_agent_enabled ? coalesce(
    var.pdc_agent.token_secret_arn,
    "arn:aws:secretsmanager:${local.observability_platform_region}:${var.observability_platform_account_id}:secret:grafana-cloud/pdc/${data.aws_caller_identity.current[0].account_id}",
  ) : null

  # Region and account of the token secret and its KMS key: arn:aws:secretsmanager:<region>:<account>:secret:<name>
  pdc_agent_token_secret_arn_parts = local.pdc_agent_enabled ? split(":", local.pdc_agent_token_secret_arn) : []

  # Grafana Cloud's PDC PrivateLink endpoints in the agent's VPC, or else the stack's cluster over the internet. The private
  # DNS names are the ones the endpoint services publish (PrivateDnsName), not the generic names in Grafana's docs.
  pdc_agent_endpoint_args = var.pdc_agent.privatelink ? [
    "-api-fqdn", "pdc-grafana-datasources-api.${local.stack.aws_region}.vpce.grafana.net",
    "-gateway-fqdn", "pdc-grafana-datasources.${local.stack.aws_region}.vpce.grafana.net",
  ] : ["-cluster", local.stack.cluster]

  # Grafana Cloud PDC API and AWS APIs on 443, and the PDC gateway SSH tunnel on 22, plus the private data sources
  pdc_agent_egress_rules = local.pdc_agent_enabled ? {
    for rule in distinct(concat(
      [for pair in setproduct(var.pdc_agent.egress_cidr_blocks, [22, 443]) : { cidr_block = pair[0], port = pair[1] }],
      var.pdc_agent.allowed_targets,
    )) : "${rule.cidr_block}-${rule.port}" => rule
  } : {}
}

data "aws_region" "current" {
  count = local.pdc_agent_enabled ? 1 : 0
}

data "aws_caller_identity" "current" {
  count = local.pdc_agent_enabled ? 1 : 0
}

# Modernisation Platform shares subnets named <business unit>-<environment>-general-private-<availability zone>
data "aws_subnets" "pdc_agent" {
  count = local.pdc_agent_enabled && var.pdc_agent.subnet_ids == null ? 1 : 0

  filter {
    name   = "tag:Name"
    values = ["*-general-private-*"]
  }

  lifecycle {
    postcondition {
      condition     = length(self.ids) > 0
      error_message = "No Modernisation Platform general private subnets were found. Set grafana_cloud.pdc_agent.subnet_ids to the private subnets the PDC agent should run in, or set grafana_cloud.pdc_agent.enabled to false."
    }
  }
}

data "aws_subnet" "pdc_agent" {
  count = local.pdc_agent_enabled ? 1 : 0

  id = local.pdc_agent_subnet_ids[0]
}

# Accounts that own several VPCs' subnets, such as core-vpc, would otherwise fail when the ECS service is created
data "aws_subnets" "pdc_agent_vpc" {
  count = local.pdc_agent_enabled && var.pdc_agent.subnet_ids == null ? 1 : 0

  filter {
    name   = "tag:Name"
    values = ["*-general-private-*"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_subnet.pdc_agent[0].vpc_id]
  }

  lifecycle {
    postcondition {
      condition     = length(self.ids) == length(data.aws_subnets.pdc_agent[0].ids)
      error_message = "Modernisation Platform general private subnets were found in more than one VPC. Set grafana_cloud.pdc_agent.subnet_ids to the private subnets the PDC agent should run in, or set grafana_cloud.pdc_agent.enabled to false."
    }
  }
}

resource "aws_iam_role" "pdc_agent_execution" {
  count = local.pdc_agent_enabled ? 1 : 0

  name = "grafana-pdc-agent-execution"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "pdc_agent_execution" {
  count = local.pdc_agent_enabled ? 1 : 0

  role       = aws_iam_role.pdc_agent_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Cross-account access also needs the resource policies on the secret and key, managed in Observability Platform
resource "aws_iam_role_policy" "pdc_agent_token" {
  count = local.pdc_agent_enabled ? 1 : 0

  name = "read-pdc-token"
  role = aws_iam_role.pdc_agent_execution[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # IAM matches the secret's full ARN, which has a six-character suffix that a partial ARN lacks
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [local.pdc_agent_token_secret_arn, "${local.pdc_agent_token_secret_arn}-??????"]
      },
      {
        # Any key in the secret's account, but only when Secrets Manager uses it to decrypt a secret
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = ["arn:aws:kms:${local.pdc_agent_token_secret_arn_parts[3]}:${local.pdc_agent_token_secret_arn_parts[4]}:key/*"]
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.${local.pdc_agent_token_secret_arn_parts[3]}.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "pdc_agent" {
  #checkov:skip=CKV_AWS_158:The agent's logs hold no sensitive data, and CloudWatch Logs encrypts them at rest by default
  count = local.pdc_agent_enabled ? 1 : 0

  name              = "/ecs/${local.pdc_agent_name}"
  retention_in_days = var.pdc_agent.log_retention_days

  tags = var.tags
}

resource "aws_security_group" "pdc_agent" {
  count = local.pdc_agent_enabled ? 1 : 0

  name        = local.pdc_agent_name
  description = "Grafana PDC agent, outbound only"
  vpc_id      = data.aws_subnet.pdc_agent[0].vpc_id

  tags = merge(var.tags, { Name = local.pdc_agent_name })
}

resource "aws_vpc_security_group_egress_rule" "pdc_agent" {
  for_each = local.pdc_agent_egress_rules

  security_group_id = aws_security_group.pdc_agent[0].id
  description       = "Allow outbound TCP ${each.value.port}"
  cidr_ipv4         = each.value.cidr_block
  from_port         = each.value.port
  to_port           = each.value.port
  ip_protocol       = "tcp"
}

resource "aws_ecs_cluster" "pdc_agent" {
  count = local.pdc_agent_enabled ? 1 : 0

  name = local.pdc_agent_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.tags
}

resource "aws_ecs_task_definition" "pdc_agent" {
  #checkov:skip=CKV_AWS_336:The agent writes SSH keys to its home directory, and Fargate volumes are not writable by its non-root user
  count = local.pdc_agent_enabled ? 1 : 0

  family                   = local.pdc_agent_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.pdc_agent.cpu
  memory                   = var.pdc_agent.memory
  execution_role_arn       = aws_iam_role.pdc_agent_execution[0].arn

  container_definitions = jsonencode([{
    name      = local.pdc_agent_name
    image     = var.pdc_agent.image
    essential = true
    # The image's non-root user, set explicitly so the task definition shows it
    user = "30000:30000"
    command = concat(local.pdc_agent_endpoint_args, [
      "-gcloud-hosted-grafana-id", local.stack.id,
      # Retry the PDC API every 30 seconds for about a day, rather than exiting after about 30 seconds, for example while
      # the VPC has no PrivateLink endpoints yet. ECS replaces tasks that exit straight away, pulling the image each time
      "-retrymax", "2880",
    ], var.pdc_agent.extra_args)
    secrets = [{
      name      = "GCLOUD_PDC_SIGNING_TOKEN"
      valueFrom = local.pdc_agent_token_secret_arn
    }]
    # The agent creates its SSH keys and known hosts under $HOME/.ssh when it starts
    readonlyRootFilesystem = false
    linuxParameters = {
      capabilities = {
        drop = ["ALL"]
      }
    }
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.pdc_agent[0].name
        awslogs-region        = data.aws_region.current[0].region
        awslogs-stream-prefix = "agent"
      }
    }
  }])

  tags = var.tags
}

resource "aws_ecs_service" "pdc_agent" {
  count = local.pdc_agent_enabled ? 1 : 0

  name            = local.pdc_agent_name
  cluster         = aws_ecs_cluster.pdc_agent[0].id
  task_definition = aws_ecs_task_definition.pdc_agent[0].arn
  launch_type     = "FARGATE"
  desired_count   = var.pdc_agent.desired_count

  # Keep tasks spread across availability zones, and replace them gradually so tunnels stay connected during restarts
  availability_zone_rebalancing      = "ENABLED"
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  # Without the circuit breaker, ECS keeps retrying tasks that fail to start, at most 27 minutes apart, so an agent
  # deployed before Observability Platform creates its token secret starts by itself once the secret exists
  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }

  network_configuration {
    subnets          = local.pdc_agent_subnet_ids
    security_groups  = [aws_security_group.pdc_agent[0].id]
    assign_public_ip = false
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "pdc_agent_running_tasks" {
  count = local.pdc_agent_enabled ? 1 : 0

  alarm_name          = "${local.pdc_agent_name}-running-tasks"
  alarm_description   = "Fewer PDC agent tasks are running than desired, so Grafana Cloud may be unable to reach private data sources"
  namespace           = "ECS/ContainerInsights"
  metric_name         = "RunningTaskCount"
  statistic           = "Minimum"
  period              = 60
  evaluation_periods  = 5
  comparison_operator = "LessThanThreshold"
  threshold           = var.pdc_agent.desired_count
  treat_missing_data  = "breaching"
  alarm_actions       = var.pdc_agent.alarm_actions
  ok_actions          = var.pdc_agent.alarm_actions

  dimensions = {
    ClusterName = aws_ecs_cluster.pdc_agent[0].name
    ServiceName = aws_ecs_service.pdc_agent[0].name
  }

  tags = var.tags
}
