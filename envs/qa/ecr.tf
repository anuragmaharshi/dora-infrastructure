resource "aws_ecr_repository" "dora_api" {
  name                 = "dora-api"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "dora-api"
    Environment = "qa"
    Project     = "dora"
  }
}

resource "aws_ecr_repository" "dora_frontend" {
  name                 = "dora-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "dora-frontend"
    Environment = "qa"
    Project     = "dora"
  }
}
