
# AWS Region
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "" # ← CHANGED from us-east-1
}

# Account IDs
variable "management_account_id" {
  description = "Management account ID"
  type        = string
}

variable "security_account_id" {
  description = "Security account ID"
  type        = string # ← FIXED typo (was string1})
}

variable "dev_account_id" {
  description = "Development account ID"
  type        = string
}

variable "prod_account_id" {
  description = "Production account ID"
  type        = string
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

# Availability Zones
variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = [""] # ← CHANGED
}

# Environment
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "security"
}

# Project Name
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "security-automation"
}
