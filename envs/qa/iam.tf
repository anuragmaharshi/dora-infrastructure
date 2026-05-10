data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ─── ECS Task Execution Role ─────────────────────────────────────────────────
# Used by ECS agent to pull images from ECR and write logs to CloudWatch.
# Also allowed to read secrets from Secrets Manager (for container env injection).

resource "aws_iam_role" "ecs_execution" {
  name               = "dora-qa-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  tags = {
    Name        = "dora-qa-ecs-execution-role"
    Environment = "qa"
    Project     = "dora"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution_managed" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_execution_secrets" {
  statement {
    sid     = "ReadQASecrets"
    actions = ["secretsmanager:GetSecretValue"]
    resources = [
      aws_secretsmanager_secret.db.arn,
      aws_secretsmanager_secret.jwt.arn,
    ]
  }
}

resource "aws_iam_role_policy" "ecs_execution_secrets" {
  name   = "dora-qa-ecs-execution-secrets"
  role   = aws_iam_role.ecs_execution.id
  policy = data.aws_iam_policy_document.ecs_execution_secrets.json
}

# ─── ECS Task Role ───────────────────────────────────────────────────────────
# Used by the application code itself (dora-api). Grants access to S3 and
# Secrets Manager. Does NOT have ECR pull or CloudWatch write permissions
# (those live on the execution role).

resource "aws_iam_role" "ecs_task" {
  name               = "dora-qa-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  tags = {
    Name        = "dora-qa-ecs-task-role"
    Environment = "qa"
    Project     = "dora"
  }
}

data "aws_iam_policy_document" "ecs_task_permissions" {
  statement {
    sid = "S3AttachmentsBucket"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.attachments.arn,
      "${aws_s3_bucket.attachments.arn}/*",
    ]
  }

  statement {
    sid     = "ReadQASecrets"
    actions = ["secretsmanager:GetSecretValue"]
    resources = [
      aws_secretsmanager_secret.db.arn,
      aws_secretsmanager_secret.jwt.arn,
    ]
  }
}

resource "aws_iam_role_policy" "ecs_task_permissions" {
  name   = "dora-qa-ecs-task-permissions"
  role   = aws_iam_role.ecs_task.id
  policy = data.aws_iam_policy_document.ecs_task_permissions.json
}
