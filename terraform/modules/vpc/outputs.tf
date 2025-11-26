# VPC Module Outputs

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "database_subnet_ids" {
  description = "IDs of database subnets"
  value       = aws_subnet.database[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

#output "nat_gateway_id" {
#  description = "ID of the NAT Gateway"
#  value       = aws_nat_gateway.main.id
#}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private.id
}

output "database_route_table_id" {
  description = "ID of the database route table"
  value       = aws_route_table.database.id
}

#═══════════════════════════════════════════════════════════════
# VPC Endpoints Outputs
#═══════════════════════════════════════════════════════════════

output "s3_endpoint_id" {
  description = "ID of the S3 VPC Endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "ec2_endpoint_id" {
  description = "ID of the EC2 VPC Endpoint"
  value       = aws_vpc_endpoint.ec2.id
}

output "vpc_endpoints_sg_id" {
  description = "ID of the VPC Endpoints security group"
  value       = aws_security_group.vpc_endpoints.id
}
