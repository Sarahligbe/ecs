output "scaling_target_id" {
  description = "Resource ID of the scaling target"
  value       = aws_appautoscaling_target.ecs_target.id
}