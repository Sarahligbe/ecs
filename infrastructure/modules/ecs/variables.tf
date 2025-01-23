variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the ALB"
  type        = list
}

variable "alb_sg_id" {
  description = "SG ID for the ALB"
  type        = string
}

variable "target_group_arn" {
  description = "ALB Target group ARN"
  type        = string
}

variable "use_public_ip" {
  description = "Whether to assign public IP to the ECS service"
  type        = bool
}