variable "project_name" {
  description = "Project name, used for resource naming"
  type        = string
}

variable "domain_name" {
  description = "Fully qualified domain name the certificate covers"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route 53 hosted zone the validation records go in"
  type        = string
}