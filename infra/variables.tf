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

variable "container_port" {
  description = "Port the container listens on. 8080 because nginx-unprivileged runs as non-root"
  type        = number
  default     = 8080
}

variable "domain_name" {
  description = "Fully qualified domain name the app is served on"
  type        = string
  default     = "postprep.labs.shuaybmohamed.co.uk"
}

variable "hosted_zone_name" {
  description = "Route 53 hosted zone the record goes in. Referenced, never created"
  type        = string
  default     = "labs.shuaybmohamed.co.uk"
}

variable "ecr_repository_name" {
  description = "ECR repository created by bootstrap"
  type        = string
  default     = "post-prep"
}

variable "image_tag" {
  description = "Image tag to deploy. Git short SHA, never latest"
  type        = string
}

variable "task_cpu" {
  description = "Fargate task CPU units. 256 = .25 vCPU"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Fargate task memory in MiB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of tasks. Two gives one per AZ"
  type        = number
  default     = 2
}