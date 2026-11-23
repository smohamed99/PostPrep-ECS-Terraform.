variable "project_name" {
  description = "Project name, used for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC the target group belongs to"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets the load balancer gets interfaces in"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group for the load balancer"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate for the HTTPS listener"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
}

variable "health_check_path" {
  description = "Path the target group health check requests"
  type        = string
  default     = "/health"
}