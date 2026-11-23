output "alb_dns_name" {
  description = "Hostname of the load balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Hosted zone of the load balancer, for the Route 53 alias"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "Target group the ECS service registers with"
  value       = aws_lb_target_group.app.arn
}

output "https_listener_arn" {
  description = "HTTPS listener ARN"
  value       = aws_lb_listener.https.arn
}