output "alb_security_group_id" {
  description = "Security group attached to the load balancer"
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "Security group attached to the ECS tasks"
  value       = aws_security_group.ecs.id
}