resource "aws_security_group" "alb" {
  name        = "dora-qa-alb-sg"
  description = "Allow HTTP inbound to ALB on ports 80, 8025, 8081"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "MailHog web UI"
    from_port   = 8025
    to_port     = 8025
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Adminer web UI"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description     = "Forward to ECS tasks"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  tags = {
    Name        = "dora-qa-alb-sg"
    Environment = "qa"
    Project     = "dora"
  }
}

resource "aws_security_group" "ecs_tasks" {
  name        = "dora-qa-ecs-tasks-sg"
  description = "Allow inbound from ALB; outbound to internet (ECR, S3, Secrets Manager)"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "From ALB — Spring Boot API"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "From ALB — nginx frontend"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "From ALB — MailHog SMTP"
    from_port       = 1025
    to_port         = 1025
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "From ALB — MailHog web UI"
    from_port       = 8025
    to_port         = 8025
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "From ALB — Adminer"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "All outbound — required for ECR pull, S3, Secrets Manager"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "dora-qa-ecs-tasks-sg"
    Environment = "qa"
    Project     = "dora"
  }
}

resource "aws_security_group" "rds" {
  name        = "dora-qa-rds-sg"
  description = "Allow PostgreSQL inbound from ECS tasks only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from ECS tasks"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "dora-qa-rds-sg"
    Environment = "qa"
    Project     = "dora"
  }
}
