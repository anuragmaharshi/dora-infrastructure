resource "aws_lb" "main" {
  name               = "dora-qa-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name        = "dora-qa-alb"
    Environment = "qa"
    Project     = "dora"
  }
}

# ─── Target Groups ───────────────────────────────────────────────────────────

resource "aws_lb_target_group" "api" {
  name        = "dora-qa-api-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/actuator/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 10
    matcher             = "200"
  }

  tags = {
    Name        = "dora-qa-api-tg"
    Environment = "qa"
    Project     = "dora"
  }
}

resource "aws_lb_target_group" "frontend" {
  name        = "dora-qa-frontend-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 10
    matcher             = "200"
  }

  tags = {
    Name        = "dora-qa-frontend-tg"
    Environment = "qa"
    Project     = "dora"
  }
}

resource "aws_lb_target_group" "mailhog" {
  name        = "dora-qa-mailhog-tg"
  port        = 8025
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 10
    matcher             = "200"
  }

  tags = {
    Name        = "dora-qa-mailhog-tg"
    Environment = "qa"
    Project     = "dora"
  }
}

resource "aws_lb_target_group" "adminer" {
  name        = "dora-qa-adminer-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 10
    matcher             = "200"
  }

  tags = {
    Name        = "dora-qa-adminer-tg"
    Environment = "qa"
    Project     = "dora"
  }
}

# ─── Listeners ───────────────────────────────────────────────────────────────

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  # Default action: forward to frontend
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_lb_listener_rule" "api_path" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

resource "aws_lb_listener_rule" "swagger_ui" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  condition {
    path_pattern {
      values = ["/swagger-ui*"]
    }
  }
}

resource "aws_lb_listener" "mailhog" {
  load_balancer_arn = aws_lb.main.arn
  port              = 8025
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mailhog.arn
  }
}

resource "aws_lb_listener" "adminer" {
  load_balancer_arn = aws_lb.main.arn
  port              = 8081
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.adminer.arn
  }
}
