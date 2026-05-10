resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/dora-api"
  retention_in_days = 7

  tags = {
    Name        = "dora-qa-api-logs"
    Environment = "qa"
    Project     = "dora"
  }
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/dora-frontend"
  retention_in_days = 7

  tags = {
    Name        = "dora-qa-frontend-logs"
    Environment = "qa"
    Project     = "dora"
  }
}

resource "aws_cloudwatch_log_group" "mailhog" {
  name              = "/ecs/dora-mailhog"
  retention_in_days = 7

  tags = {
    Name        = "dora-qa-mailhog-logs"
    Environment = "qa"
    Project     = "dora"
  }
}

resource "aws_cloudwatch_log_group" "adminer" {
  name              = "/ecs/dora-adminer"
  retention_in_days = 7

  tags = {
    Name        = "dora-qa-adminer-logs"
    Environment = "qa"
    Project     = "dora"
  }
}
