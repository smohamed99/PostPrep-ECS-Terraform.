output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets - the ALB goes here"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets - ECS tasks go here"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_public_ips" {
  description = "Public IPs traffic leaves from"
  value       = aws_eip.nat[*].public_ip
}

output "alb_dns_name" {
  description = "ALB hostname - useful for testing before DNS propagates"
  value       = aws_lb.main.dns_name
}

output "app_url" {
  description = "The live application URL"
  value       = "https://${var.domain_name}"
}

output "ecs_cluster_name" {
  description = "Cluster name, for the AWS CLI debug commands"
  value       = aws_ecs_cluster.main.name
}