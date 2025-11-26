
# Main Terraform Configuration
# This is the entry point that uses all the modules

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name          = var.project_name
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  availability_zones    = var.availability_zones
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security-groups"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id

  # This ensures security groups are created after VPC
  depends_on = [module.vpc]
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
}



# SNS Topic for Security Alerts
resource "aws_sns_topic" "security_alerts" {
  name = "${var.project_name}-security-alerts"

  tags = {
    Name = "${var.project_name}-security-alerts"
  }
}

# SNS Topic Subscription (Email)
resource "aws_sns_topic_subscription" "security_alerts_email" {
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = "" # ← UPDATE: Your email address

  # Note: You'll need to confirm the subscription via email after creation
}

# S3 Bucket for Lambda deployment packages
resource "aws_s3_bucket" "lambda_deployments" {
  bucket = "${var.project_name}-lambda-deployments-${var.security_account_id}"

  tags = {
    Name = "${var.project_name}-lambda-deployments"
  }
}

# Enable versioning on Lambda deployment bucket
resource "aws_s3_bucket_versioning" "lambda_deployments" {
  bucket = aws_s3_bucket.lambda_deployments.id

  versioning_configuration {
    status = "Enabled"
  }
}



# VPC Endpoints


output "vpc_endpoints" {
  description = "VPC Endpoint IDs"
  value = {
    s3_endpoint  = module.vpc.s3_endpoint_id
    ec2_endpoint = module.vpc.ec2_endpoint_id
    endpoints_sg = module.vpc.vpc_endpoints_sg_id
  }
}

output "cost_summary" {
  description = "Monthly cost breakdown"
  value = {
    vpc_endpoints  = "$7.20/month (EC2 interface endpoint)"
    s3_endpoint    = "FREE (Gateway endpoint)"
    guardduty      = "$5/month (30-day free trial)"
    flow_logs      = "~$2/month (S3 storage)"
    cloudwatch     = "~$1/month"
    lambda         = "FREE (under 1M requests)"
    config         = "FREE (under 100K evaluations)"
    total_monthly  = "~$8-10/month"
    savings_vs_nat = "$35-40/month saved (no NAT Gateway!)"
  }
}

# Encrypt Lambda deployment bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_deployments" {
  bucket = aws_s3_bucket.lambda_deployments.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

}


# NETWORK ACLs MODULE


module "network_acls" {
  source = "./modules/network-acls"

  project_name        = var.project_name
  vpc_id              = module.vpc.vpc_id
  vpc_cidr            = var.vpc_cidr
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids
  database_subnet_ids = module.vpc.database_subnet_ids

  # Change this to YOUR home/office IP for SSH access
  admin_ip_cidr = "0.0.0.0/0" # ⚠️ CHANGE THIS!

  # Add malicious IPs discovered from flow logs
  blocked_ips = [
    "203.0.113.0/24",   # TEST-NET-3 (IANA documentation range)
    "198.51.100.0/24",  # TEST-NET-2 (safe placeholder)
    "192.0.2.0/24",     # TEST-NET-1 (safe placeholder)
    "100.100.100.0/24", # Example "malicious" range for demo
    "45.155.205.0/24"   # Known scanning network (common in labs)
  ]


  depends_on = [module.vpc]
}
