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

variable "vpc_cidr" {
  description = "CIDR block for the VPC. A /22 gives 1024 addresses, divided into eight /25 blocks"
  type        = string
  default     = "10.0.0.0/22"
}

variable "az_count" {
  description = "Number of availability zones. Two is the minimum an ALB requires"
  type        = number
  default     = 2
}