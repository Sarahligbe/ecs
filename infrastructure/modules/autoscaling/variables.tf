variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type = string
}

variable "ecs_service_name" {
  description = "ECS cluster service name"
  type = string
}

variable "min_capacity" {
  description = "minimum number of tasks"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "maximum number of tasks"
  type        = number
  default     = 5
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the ALB"
  type        = string
}

variable "alb_tg_arn_suffix" {
  description = "ARN suffix of the ALB Target group"
  type        = string
}