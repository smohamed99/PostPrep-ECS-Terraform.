variable "project_name" {
  description = "Project name, used for resource naming"
  type        = string
}

variable "aws_region" {
  description = "Region, needed for the CloudWatch log driver configuration"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets the tasks run in"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group for the tasks"
  type        = string
}

variable "target_group_arn" {
  description = "Target group the service registers tasks with"
  type        = string
}

variable "ecr_repository_name" {
  description = "ECR repository holding the image. Created by bootstrap/"
  type        = string
}

variable "image_tag" {
  description = "Image tag to deploy. Git short SHA, never latest"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
}

variable "task_cpu" {
  description = "Fargate task CPU units"
  type        = number
}

variable "task_memory" {
  description = "Fargate task memory in MiB"
  type        = number
}

variable "desired_count" {
  description = "Number of tasks to run"
  type        = number
}

variable "log_retention_days" {
  description = "CloudWatch log retention"
  type        = number
  default     = 7
}