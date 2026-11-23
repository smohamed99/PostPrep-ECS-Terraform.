output "repository_url" {
  description = "Registry URL to tag and push against"
  value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  description = "Repository ARN - needed later to scope the CI build-push policy"
  value       = aws_ecr_repository.this.arn
}

output "repository_name" {
  description = "Repository name"
  value       = aws_ecr_repository.this.name
}