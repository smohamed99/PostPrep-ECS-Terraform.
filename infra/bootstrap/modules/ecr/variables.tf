variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "MUTABLE or IMMUTABLE. Immutable prevents a tag being repointed at a different image"
  type        = string
  default     = "IMMUTABLE"
}

variable "scan_on_push" {
  description = "Scan images for vulnerabilities on push"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption used for images at rest"
  type        = string
  default     = "AES256"
}

variable "image_retention_count" {
  description = "Number of tagged images to keep"
  type        = number
  default     = 20
}