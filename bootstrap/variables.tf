variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Project name, used for tagging and resource naming"
  type        = string
  default     = "post-prep"
}

variable "state_bucket_name" {
  description = "Globally unique name for the S3 bucket holding Terraform state"
  type        = string
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository holding the application image"
  type        = string
  default     = "post-prep"
}

variable "image_tag_mutability" {
  description = "IMMUTABLE prevents a tag being repointed at a different image"
  type        = string
  default     = "IMMUTABLE"
}

variable "scan_on_push" {
  description = "Scan images for vulnerabilities when they are pushed"
  type        = bool
  default     = true
}

variable "image_retention_count" {
  description = "Number of tagged images to keep before expiring the oldest"
  type        = number
  default     = 20
}