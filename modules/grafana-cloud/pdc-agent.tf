# Private Data Source Connect (PDC) agent, run on ECS Fargate.
#
# The signing token is held in a Secrets Manager secret in the Observability Platform account,
# encrypted with a customer managed KMS key. Both the secret policy and key policy there only trust a role
# named "grafana-pdc-agent-execution", so that name must not change.

locals {
  pdc_agent_enabled = var.features.pdc_agent
  pdc_agent_name    = "grafana-pdc-agent"
}

data "aws_region" "current" {}

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
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [var.pdc_agent.token_secret_arn]
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = [var.pdc_agent.token_kms_key_arn]
      }
    ]
  })
}

# The agent only makes outbound connections and needs no AWS permissions of its own
resource "aws_iam_role" "pdc_agent_task" {
  count = local.pdc_agent_enabled ? 1 : 0

  name = "grafana-pdc-agent-task"
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

resource "aws_cloudwatch_log_group" "pdc_agent" {
  count = local.pdc_agent_enabled ? 1 : 0

  name              = "/ecs/${local.pdc_agent_name}"
  retention_in_days = var.pdc_agent.log_retention_days

  tags = var.tags
}

resource "aws_security_group" "pdc_agent" {
  count = local.pdc_agent_enabled ? 1 : 0

  name        = local.pdc_agent_name
  description = "Grafana PDC agent, outbound only"
  vpc_id      = var.pdc_agent.vpc_id

  tags = merge(var.tags, { Name = local.pdc_agent_name })
}

# HTTPS for the PDC API and AWS endpoints, SSH for the tunnel to the PDC gateway
resource "aws_vpc_security_group_egress_rule" "pdc_agent" {
  for_each = local.pdc_agent_enabled ? {
    for pair in setproduct(var.pdc_agent.egress_cidr_blocks, [22, 443]) : "${pair[0]}-${pair[1]}" => pair
  } : {}

  security_group_id = aws_security_group.pdc_agent[0].id
  description       = "Allow outbound ${each.value[1]}"
  cidr_ipv4         = each.value[0]
  from_port         = each.value[1]
  to_port           = each.value[1]
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
  count = local.pdc_agent_enabled ? 1 : 0

  family                   = local.pdc_agent_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.pdc_agent.cpu
  memory                   = var.pdc_agent.memory
  execution_role_arn       = aws_iam_role.pdc_agent_execution[0].arn
  task_role_arn            = aws_iam_role.pdc_agent_task[0].arn

  container_definitions = jsonencode([{
    name      = local.pdc_agent_name
    image     = var.pdc_agent.image
    essential = true
    command = concat([
      "-cluster", var.pdc_agent.cluster_name,
      "-gcloud-hosted-grafana-id", var.stack_id,
    ], var.pdc_agent.extra_args)
    secrets = [{
      name      = "GCLOUD_PDC_SIGNING_TOKEN"
      valueFrom = var.pdc_agent.token_secret_arn
    }]
    readonlyRootFilesystem = true
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.pdc_agent[0].name
        awslogs-region        = data.aws_region.current.region
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

  # Replace tasks gradually so tunnels stay connected during restarts
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets          = var.pdc_agent.subnet_ids
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
