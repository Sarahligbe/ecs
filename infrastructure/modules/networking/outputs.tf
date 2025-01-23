output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of IDs for public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs for private subnets"
  value       = aws_subnet.private[*].id
}

output "subnet_ids" {
  value = var.enable_private_networking ? aws_subnet.private[*].id : aws_subnet.public[*].id
}

output "use_public_ip" {
  value = !var.enable_private_networking
}