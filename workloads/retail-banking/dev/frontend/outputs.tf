output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.frontend.dns_name
}

output "alb_url" {
  description = "Retail Banking frontend URL"
  value       = "http://${aws_lb.frontend.dns_name}"
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.frontend.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.frontend.name
}

output "ecs_task_definition" {
  description = "ECS task definition"
  value       = aws_ecs_task_definition.frontend.family
}