# Security Groups Module Outputs

output "web_sg_id" {
  description = "ID of the web tier security group"
  value       = aws_security_group.web.id
}

output "app_sg_id" {
  description = "ID of the app tier security group"
  value       = aws_security_group.app.id
}

output "db_sg_id" {
  description = "ID of the database tier security group"
  value       = aws_security_group.db.id
}

output "web_sg_name" {
  description = "Name of the web tier security group"
  value       = aws_security_group.web.name
}

output "app_sg_name" {
  description = "Name of the app tier security group"
  value       = aws_security_group.app.name
}

output "db_sg_name" {
  description = "Name of the database tier security group"
  value       = aws_security_group.db.name
}
