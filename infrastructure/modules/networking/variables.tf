variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "172.19.0.0/16"
}

variable "enable_private_networking" {
  description = "Enable private subnets and NAT Gateway for ECS"
  type        = bool
  default     = false
}

variable "private_subnet_count" {
  description = "Number of private subnets to create"
  type        = number
  default     = 2
}

variable "public_subnet_count" {
  description = "Number of public subnets to create"
  type        = number
  default     = 2
}