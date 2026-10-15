terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# provider "aws" {
#   region = var.aws_region

#   assume_role {
#     role_arn = "arn:aws:iam::967172220355:role/OrganizationAccountAccessRole"
#   }
# }


provider "aws" {
  region  = var.aws_region
  profile = "retailprod"
}



# ------------------------------------------------------------
# ECS Cluster
# ------------------------------------------------------------

resource "aws_ecs_cluster" "frontend" {
  name = "${var.app_name}-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Application = "RetailBanking"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ------------------------------------------------------------
# CloudWatch Log Group
# ------------------------------------------------------------

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/${var.app_name}-${var.environment}"
  retention_in_days = 7

  tags = {
    Application = "RetailBanking"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ------------------------------------------------------------
# ECS Task Execution Role
# ------------------------------------------------------------

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.app_name}-${var.environment}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Application = "RetailBanking"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ------------------------------------------------------------
# ECS Task Execution Policy
# ------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# ------------------------------------------------------------
# ALB Security Group
# ------------------------------------------------------------

resource "aws_security_group" "alb" {
  name        = "${var.app_name}-${var.environment}-alb-sg"
  description = "Security group for Retail Banking frontend ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-${var.environment}-alb-sg"
    Application = "RetailBanking"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ------------------------------------------------------------
# ECS Security Group
# ------------------------------------------------------------

resource "aws_security_group" "ecs" {
  name        = "${var.app_name}-${var.environment}-ecs-sg"
  description = "Security group for Retail Banking frontend ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Node.js traffic from ALB"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-${var.environment}-ecs-sg"
    Application = "RetailBanking"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ------------------------------------------------------------
# Application Load Balancer
# ------------------------------------------------------------

resource "aws_lb" "frontend" {
  name               = "${var.app_name}-${var.environment}"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = var.public_subnets

  tags = {
    Name        = "${var.app_name}-${var.environment}"
    Application = "RetailBanking"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ------------------------------------------------------------
# ALB Target Group
# ------------------------------------------------------------

resource "aws_lb_target_group" "frontend" {
  name        = "${var.app_name}-${var.environment}"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Application = "RetailBanking"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ------------------------------------------------------------
# ALB HTTP Listener
# ------------------------------------------------------------

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn = aws_lb_target_group.frontend.arn
      }
    }
  }

  tags = {
    Application = "RetailBanking"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


# ------------------------------------------------------------
# ECS Task Definition
# ------------------------------------------------------------

resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.app_name}-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = var.app_name
      image = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.app_name}:dev"

      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NODE_ENV"
          value = var.environment
        },
        {
          name  = "PORT"
          value = tostring(var.container_port)
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.frontend.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "frontend"
        }
      }
    }
  ])

  tags = {
    Application = "RetailBanking"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


# ------------------------------------------------------------
# ECS Service
# ------------------------------------------------------------

resource "aws_ecs_service" "frontend" {
  name            = "${var.app_name}-${var.environment}"
  cluster         = aws_ecs_cluster.frontend.id
  task_definition = aws_ecs_task_definition.frontend.arn

  desired_count = var.desired_count

  launch_type = "FARGATE"

  network_configuration {
    subnets = var.private_subnets

    security_groups = [
      aws_security_group.ecs.id
    ]

    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = var.app_name
    container_port   = var.container_port
  }

  depends_on = [
    aws_lb_listener.frontend,
    aws_iam_role_policy_attachment.ecs_task_execution
  ]

  tags = {
    Application = "RetailBanking"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}