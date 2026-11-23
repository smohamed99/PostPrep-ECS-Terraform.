output "bucket_name" {
  description = "Name of the bucket"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "ARN of the bucket - needed later to scope the CI deploy policy"
  value       = aws_s3_bucket.this.arn
}