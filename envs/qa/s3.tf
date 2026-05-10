resource "aws_s3_bucket" "attachments" {
  bucket        = "dora-qa-attachments"
  force_destroy = true

  tags = {
    Name        = "dora-qa-attachments"
    Environment = "qa"
    Project     = "dora"
  }
}

resource "aws_s3_bucket_public_access_block" "attachments" {
  bucket = aws_s3_bucket.attachments.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "attachments_bucket_policy" {
  statement {
    sid    = "AllowECSTaskRole"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.ecs_task.arn]
    }

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
    ]

    resources = ["${aws_s3_bucket.attachments.arn}/*"]
  }

  statement {
    sid    = "AllowECSTaskRoleList"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.ecs_task.arn]
    }

    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.attachments.arn]
  }
}

resource "aws_s3_bucket_policy" "attachments" {
  bucket = aws_s3_bucket.attachments.id
  policy = data.aws_iam_policy_document.attachments_bucket_policy.json

  depends_on = [aws_s3_bucket_public_access_block.attachments]
}
