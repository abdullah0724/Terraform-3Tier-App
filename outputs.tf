# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

# Subnet Outputs
output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "database_subnet_ids" {
  description = "IDs of the database subnets"
  value       = [aws_subnet.db_1.id, aws_subnet.db_2.id]
}

# EC2 Outputs
output "frontend_public_ip" {
  description = "Public IP address of the frontend EC2 instance"
  value       = aws_instance.frontend.public_ip
}

output "frontend_private_ip" {
  description = "Private IP address of the frontend EC2 instance"
  value       = aws_instance.frontend.private_ip
}

output "backend_private_ip" {
  description = "Private IP address of the backend EC2 instance"
  value       = aws_instance.backend.private_ip
}

# RDS Outputs
output "database_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "database_port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

# Application URLs
output "application_url" {
  description = "URL to access the frontend application"
  value       = "http://${aws_instance.frontend.public_ip}"
}

output "backend_health_url" {
  description = "URL to check backend health (via frontend proxy)"
  value       = "http://${aws_instance.frontend.public_ip}/api/"
}

# Security Group IDs
output "frontend_security_group_id" {
  description = "ID of the frontend security group"
  value       = aws_security_group.frontend.id
}

output "backend_security_group_id" {
  description = "ID of the backend security group"
  value       = aws_security_group.backend.id
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.database.id
}

# Connection Information
output "private_key_file" {
  description = "Path to the generated private key file"
  value       = local_file.private_key.filename
}

output "key_pair_name" {
  description = "Name of the created key pair"
  value       = aws_key_pair.main.key_name
}

output "ssh_command_frontend" {
  description = "SSH command to connect to the frontend instance"
  value       = "ssh -i ${local_file.private_key.filename} ec2-user@${aws_instance.frontend.public_ip}"
}

output "ssh_command_backend" {
  description = "SSH command to connect to the backend instance (via frontend)"
  value       = "ssh -i ${local_file.private_key.filename} -o ProxyCommand='ssh -i ${local_file.private_key.filename} -W %h:%p ec2-user@${aws_instance.frontend.public_ip}' ec2-user@${aws_instance.backend.private_ip}"
}