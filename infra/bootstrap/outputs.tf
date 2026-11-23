output "state_bucket_name" {
  description = "Name of the S3 bucket holding Terraform state"
  value       = aws_s3_bucket.tfstate.bucket
}

output "state_bucket_arn" {
  description = "Bucket ARN - needed later to scope the CI deploy policy"
  value       = aws_s3_bucket.tfstate.arn
}

output "ecr_repository_url" {
  description = "Registry URL to tag and push images against"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_arn" {
  description = "Repository ARN - needed later to scope the CI build-push policy"
  value       = aws_ecr_repository.app.arn
}