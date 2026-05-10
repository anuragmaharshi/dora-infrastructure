output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "frontend_url" {
  description = "URL of the Angular frontend (Angular app loads here)."
  value       = "http://${aws_lb.main.dns_name}/"
}

output "api_url" {
  description = "Base URL for the dora-api (Spring Boot, context-path /api)."
  value       = "http://${aws_lb.main.dns_name}/api"
}

output "swagger_url" {
  description = "URL for Swagger UI."
  value       = "http://${aws_lb.main.dns_name}/swagger-ui.html"
}

output "mailhog_url" {
  description = "URL for MailHog web UI (captured outbound emails)."
  value       = "http://${aws_lb.main.dns_name}:8025/"
}

output "adminer_url" {
  description = "URL for Adminer DB browser. Connect to RDS endpoint with user=dora, db=dora."
  value       = "http://${aws_lb.main.dns_name}:8081/"
}

output "ecr_dora_api_url" {
  description = "ECR repository URL for dora-api image."
  value       = aws_ecr_repository.dora_api.repository_url
}

output "ecr_dora_frontend_url" {
  description = "ECR repository URL for dora-frontend image."
  value       = aws_ecr_repository.dora_frontend.repository_url
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint (host:port). Use in Adminer to connect."
  value       = aws_db_instance.postgres.endpoint
  sensitive   = false
}
