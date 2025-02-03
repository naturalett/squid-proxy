resource "aws_security_group" "nlb_sg" {
  name_prefix = "nlb-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "nlb" {
  name               = "${var.name}-nlb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.nlb_sg.id]
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "nlb_target_group" {
  name        = "${var.name}-tg"
  port        = 443
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  tags = {
    "Name"        = "squid-target-group"
    "App"         = "SquidApp"
    "Environment" = var.environment
  }
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 443
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_target_group.arn
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name}-ecs-cluster"
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "${var.name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.execution_role_arn


  container_definitions = jsonencode([
    {
      name      = "squid-container"
      image     = "${var.account_id}.dkr.ecr.us-east-1.amazonaws.com/squid:ssl-passwd"
      essential = true
      portMappings = [
        {
          containerPort = 3128
          hostPort      = 3128
          protocol      = "tcp"
          name          = "squid-3128-tcp"
          appProtocol   = "http"
        },
        {
          containerPort = 443
          hostPort      = 443
          protocol      = "tcp"
        }
      ]
    }
  ])
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${var.name}-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.nlb_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nlb_target_group.arn
    container_name   = "squid-container"
    container_port   = 3128
  }

  tags = {
    "Name"              = "squid-service"
    "Environment"       = var.environment
    "ServiceType"       = "Web"
    "AppName"           = "SquidApp"
    "ECSCluster"        = aws_ecs_cluster.ecs_cluster.name
  }
}
