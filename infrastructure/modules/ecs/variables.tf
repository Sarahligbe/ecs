variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = list
}

variable "alb_sg_id" {
  description = "SG ID for the ALB"
  type        = string
}