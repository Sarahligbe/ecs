variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type = string
  default = "rosa-test"
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

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "172.19.0.0/16"
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