variable "project_name" {
  description = "Project name, used for resource naming"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "az_count" {
  description = "Number of availability zones to span"
  type        = number
}