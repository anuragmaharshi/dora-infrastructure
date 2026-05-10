variable "db_password" {
  description = "Password for the RDS PostgreSQL dora user. Min 16 chars. Never commit — keep in terraform.tfvars."
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "HS256 signing secret used by DevJwtService. Min 32 chars. Never commit — keep in terraform.tfvars."
  type        = string
  sensitive   = true
}

variable "aws_account_id" {
  description = "AWS account ID — used to construct ECR URLs and IAM ARNs."
  type        = string
}
