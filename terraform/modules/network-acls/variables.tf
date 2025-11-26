variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where NACLs will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "database_subnet_ids" {
  description = "List of database subnet IDs"
  type        = list(string)
}

variable "admin_ip_cidr" {
  description = "Admin IP address for SSH access (your IP)"
  type        = string
  default     = "0.0.0.0/0" # Change to YOUR IP for better security!
}

variable "blocked_ips" {
  description = "List of IP addresses to block (known attackers)"
  type        = list(string)
  default = [
    "203.0.113.0/24", # Example malicious subnet
    # Add more IPs from your threat intelligence feeds
  ]
}
