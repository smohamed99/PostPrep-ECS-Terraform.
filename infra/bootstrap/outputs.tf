output "state_bucket_name" {
  description = "Name of the S3 bucket holding Terraform state"
  value       = module.s3.bucket_name
}

output "state_bucket_arn" {
  description = "Bucket ARN - needed later to scope the CI deploy policy"
  value       = module.s3.bucket_arn
}

output "ecr_repository_url" {
  description = "Registry URL to tag and push images against"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "Repository ARN - needed later to scope the CI build-push policy"
  value       = module.ecr.repository_arn
}