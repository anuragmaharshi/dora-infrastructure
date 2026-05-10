resource "aws_ecs_cluster" "main" {
  name = "dora-qa"

  tags = {
    Name        = "dora-qa"
    Environment = "qa"
    Project     = "dora"
  }
}

# ─── Task Definition: dora-api ───────────────────────────────────────────────

resource "aws_ecs_task_definition" "api" {
  family                   = "dora-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "dora-api"
      image     = "${aws_ecr_repository.dora_api.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "SERVER_SERVLET_CONTEXT_PATH"
          value = "/api"
        },
        {
          name  = "SPRING_PROFILES_ACTIVE"
          value = "qa"
        },
        # S3_ENDPOINT and MINIO_PUBLIC_URL intentionally unset — SDK uses real AWS S3
      ]

      secrets = [
        {
          name      = "DB_SECRET"
          valueFrom = aws_secretsmanager_secret.db.arn
        },
        {
          name      = "JWT_SECRET_JSON"
          valueFrom = aws_secretsmanager_secret.jwt.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.api.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "wget -q -O /dev/null http://localhost:8080/api/actuator/health || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = {
    Name        = "dora-api"
    Environment = "qa"
    Project     = "dora"
  }
}

# ─── Task Definition: dora-frontend ─────────────────────────────────────────

resource "aws_ecs_task_definition" "frontend" {
  family                   = "dora-frontend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([
    {
      name      = "dora-frontend"
      image     = "${aws_ecr_repository.dora_frontend.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.frontend.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "wget -q -O /dev/null http://localhost:80/ || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 30
      }
    }
  ])

  tags = {
    Name        = "dora-frontend"
    Environment = "qa"
    Project     = "dora"
  }
}

# ─── Task Definition: dora-mailhog ──────────────────────────────────────────

resource "aws_ecs_task_definition" "mailhog" {
  family                   = "dora-mailhog"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([
    {
      name      = "dora-mailhog"
      image     = "mailhog/mailhog:v1.0.1"
      essential = true

      portMappings = [
        {
          containerPort = 1025
          protocol      = "tcp"
        },
        {
          containerPort = 8025
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.mailhog.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "dora-mailhog"
    Environment = "qa"
    Project     = "dora"
  }
}

# ─── Task Definition: dora-adminer ──────────────────────────────────────────

resource "aws_ecs_task_definition" "adminer" {
  family                   = "dora-adminer"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([
    {
      name      = "dora-adminer"
      image     = "adminer:4.8.1"
      essential = true

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.adminer.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "dora-adminer"
    Environment = "qa"
    Project     = "dora"
  }
}

# ─── ECS Services ────────────────────────────────────────────────────────────

resource "aws_ecs_service" "api" {
  name            = "dora-api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "dora-api"
    container_port   = 8080
  }

  depends_on = [
    aws_lb_listener.http,
    aws_db_instance.postgres,
    aws_iam_role_policy_attachment.ecs_execution_managed,
  ]

  tags = {
    Name        = "dora-api"
    Environment = "qa"
    Project     = "dora"
  }
}

resource "aws_ecs_service" "frontend" {
  name            = "dora-frontend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "dora-frontend"
    container_port   = 80
  }

  depends_on = [
    aws_lb_listener.http,
    aws_iam_role_policy_attachment.ecs_execution_managed,
  ]

  tags = {
    Name        = "dora-frontend"
    Environment = "qa"
    Project     = "dora"
  }
}

resource "aws_ecs_service" "mailhog" {
  name            = "dora-mailhog"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.mailhog.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.mailhog.arn
    container_name   = "dora-mailhog"
    container_port   = 8025
  }

  depends_on = [
    aws_lb_listener.mailhog,
    aws_iam_role_policy_attachment.ecs_execution_managed,
  ]

  tags = {
    Name        = "dora-mailhog"
    Environment = "qa"
    Project     = "dora"
  }
}

resource "aws_ecs_service" "adminer" {
  name            = "dora-adminer"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.adminer.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.adminer.arn
    container_name   = "dora-adminer"
    container_port   = 8080
  }

  depends_on = [
    aws_lb_listener.adminer,
    aws_iam_role_policy_attachment.ecs_execution_managed,
  ]

  tags = {
    Name        = "dora-adminer"
    Environment = "qa"
    Project     = "dora"
  }
}
