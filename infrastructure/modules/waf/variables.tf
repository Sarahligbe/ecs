variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type = string
}

variable "rate_limit" {
  description = "Number of requests allowed per 5 minutes per IP"
  type        = number
  default     = 2000
}

variable "captcha_limit" {
  description = "Number of requests before CAPTCHA challenge"
  type        = number
  default     = 100
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer"
  type        = string
}