output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets - the ALB lives here"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets - ECS tasks live here"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_public_ips" {
  description = "Public IPs outbound traffic leaves from"
  value       = module.vpc.nat_gateway_public_ips
}

output "alb_dns_name" {
  description = "ALB hostname - useful for testing before DNS propagates"
  value       = module.alb.alb_dns_name
}

output "app_url" {
  description = "The live application URL"
  value       = "https://${var.domain_name}"
}

output "ecs_cluster_name" {
  description = "Cluster name, for the AWS CLI debug commands"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Service name, for the AWS CLI debug commands"
  value       = module.ecs.service_name
}