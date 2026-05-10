# ---------------------------------------------------------------------------
# Security Groups — shells only (no inline ingress/egress blocks).
# All rules are defined as separate aws_security_group_rule resources below
# to break the cycle between alb and ecs_tasks.
# ---------------------------------------------------------------------------

resource "aws_security_group" "alb" {
  name        = "dora-qa-alb-sg"
  description = "Allow HTTP inbound to ALB on ports 80, 8025, 8081"
  vpc_id      = aws_vpc.main.id

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

# ---------------------------------------------------------------------------
# ALB security group rules
# ---------------------------------------------------------------------------

resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTP"
}

resource "aws_security_group_rule" "alb_ingress_mailhog_ui" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  from_port         = 8025
  to_port           = 8025
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "MailHog web UI"
}

resource "aws_security_group_rule" "alb_ingress_adminer_ui" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  from_port         = 8081
  to_port           = 8081
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Adminer web UI"
}

resource "aws_security_group_rule" "alb_egress_to_ecs" {
  type                     = "egress"
  security_group_id        = aws_security_group.alb.id
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.ecs_tasks.id
  description              = "Forward to ECS tasks"
}

# ---------------------------------------------------------------------------
# ECS tasks security group rules
# ---------------------------------------------------------------------------

# Port 8080 from ALB covers both Spring Boot API and Adminer (both listen on
# 8080 inside their respective containers). A single rule suffices because the
# protocol/port/source combination is identical.
resource "aws_security_group_rule" "ecs_ingress_api" {
  type                     = "ingress"
  security_group_id        = aws_security_group.ecs_tasks.id
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  description              = "From ALB - Spring Boot API and Adminer (both port 8080)"
}

resource "aws_security_group_rule" "ecs_ingress_frontend" {
  type                     = "ingress"
  security_group_id        = aws_security_group.ecs_tasks.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  description              = "From ALB - nginx frontend"
}

resource "aws_security_group_rule" "ecs_ingress_mailhog_smtp" {
  type                     = "ingress"
  security_group_id        = aws_security_group.ecs_tasks.id
  from_port                = 1025
  to_port                  = 1025
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  description              = "From ALB - MailHog SMTP"
}

resource "aws_security_group_rule" "ecs_ingress_mailhog_ui" {
  type                     = "ingress"
  security_group_id        = aws_security_group.ecs_tasks.id
  from_port                = 8025
  to_port                  = 8025
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  description              = "From ALB - MailHog web UI"
}

resource "aws_security_group_rule" "ecs_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.ecs_tasks.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "All outbound - required for ECR pull, S3, Secrets Manager"
}
