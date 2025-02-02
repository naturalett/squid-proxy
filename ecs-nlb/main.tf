module "ecs_with_nlb" {
  source = "./modules/ecs_with_nlb"

  name                = var.name
  account_id          = var.account_id
  environment         = var.env
  vpc_id              = data.aws_vpc.selected.id
  subnet_ids          = data.aws_subnets.public.ids
  acm_certificate_arn = var.acm_certificate_arn
  execution_role_arn  = aws_iam_role.execution_role.arn
}

# IAM role for the ECS Task Definition
resource "aws_iam_role" "execution_role" {
  name = "ecs-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "execution_role_policy" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "create_log_group_policy" {
  name = "CreateLogGroupPolicy"
  role = aws_iam_role.execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup"]
        Resource = "*"
      }
    ]
  })
}


# IAM role for the EventBridge Schedule
resource "aws_iam_role" "eventbridge_execution_role" {
  name = "eventbridge-scheduler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "eventbridge_policy" {
  name        = "eventbridge-ecs-policy"
  description = "Policy for EventBridge Scheduler to update ECS service"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowUpdateService"
        Effect = "Allow"
        Action = "ecs:UpdateService"
        Resource = [
          "arn:aws:ecs:us-east-1:${var.account_id}:cluster/${var.name}-ecs-cluster",
          "arn:aws:ecs:us-east-1:${var.account_id}:service/${var.name}-ecs-cluster/${var.name}-service"
        ]
      },
      {
        Sid    = "AllowPassRole"
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = "arn:aws:iam::${var.account_id}:role/ecsTaskExecutionRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eventbridge_policy_attach" {
  role       = aws_iam_role.eventbridge_execution_role.name
  policy_arn = aws_iam_policy.eventbridge_policy.arn
}

resource "aws_scheduler_schedule" "ecs_update_schedule" {
  name                 = "ecs-update-service-schedule"
  schedule_expression  = "rate(6 minutes)"
  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
    role_arn = aws_iam_role.eventbridge_execution_role.arn

    input = jsonencode({
      "Cluster"           : "arn:aws:ecs:us-east-1:${var.account_id}:cluster/${var.name}-ecs-cluster",
      "Service"           : "arn:aws:ecs:us-east-1:${var.account_id}:service/${var.name}-ecs-cluster/${var.name}-service",
      "DesiredCount"      : 2,
      "ForceNewDeployment" : true
    })
  }
}
