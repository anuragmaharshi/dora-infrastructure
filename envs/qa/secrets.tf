resource "aws_secretsmanager_secret" "db" {
  name        = "dora/qa/db"
  description = "PostgreSQL credentials for dora-qa RDS instance. Rotate by updating terraform.tfvars and re-applying."

  tags = {
    Name        = "dora-qa-db-secret"
    Environment = "qa"
    Project     = "dora"
  }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = "dora"
    password = var.db_password
  })
}

resource "aws_secretsmanager_secret" "jwt" {
  name        = "dora/qa/jwt"
  description = "JWT signing secret used by DevJwtService. Rotate by updating terraform.tfvars and re-applying."

  tags = {
    Name        = "dora-qa-jwt-secret"
    Environment = "qa"
    Project     = "dora"
  }
}

resource "aws_secretsmanager_secret_version" "jwt" {
  secret_id = aws_secretsmanager_secret.jwt.id
  secret_string = jsonencode({
    secret = var.jwt_secret
  })
}
