variable "project_name" {
  description = "Project name, used for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC the security groups belong to"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
}