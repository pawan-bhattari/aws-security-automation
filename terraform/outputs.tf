# outputs.tf
# Terraform Outputs - Values displayed after successful deployment
# These provide important information about deployed infrastructure

# ============================================================================
# NETWORK OUTPUTS
# ============================================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  description = "IDs of database subnets"
  value       = module.vpc.database_subnet_ids
}

# ============================================================================
# SECURITY GROUP OUTPUTS
# ============================================================================

output "security_group_ids" {
  description = "Security group IDs for each tier"
  value = {
    web = module.security_groups.web_sg_id
    app = module.security_groups.app_sg_id
    db  = module.security_groups.db_sg_id
  }
}

# ============================================================================
# ACCOUNT INFORMATION
# ============================================================================

output "account_ids" {
  description = "AWS Account IDs in organization"
  value = {
    management = var.management_account_id
    security   = var.security_account_id
    dev        = var.dev_account_id
  }
  sensitive = true # Hide account IDs from console output
}

output "deployed_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

output "environment" {
  description = "Current environment"
  value       = var.environment
}

# ============================================================================
# ORGANIZATIONAL OUTPUTS
# ============================================================================

output "organization_info" {
  description = "AWS Organization structure information"
  value = {
    management_account = var.management_account_id
    security_ou        = "ou-vyd1-wdmugy5c"
    workloads_ou       = "ou-vyd1-rgowgcmh"
    primary_region     = var.aws_region
  }
  sensitive = true
}



#═══════════════════════════════════════════════════════════════
# VPC Flow Logs
#═══════════════════════════════════════════════════════════════

output "flow_logs_bucket" {
  description = "S3 bucket for VPC Flow Logs"
  value       = aws_s3_bucket.flow_logs.id
}

output "flow_logs_bucket_arn" {
  description = "ARN of Flow Logs bucket"
  value       = aws_s3_bucket.flow_logs.arn
}

output "vpc_flow_log_id" {
  description = "ID of the VPC Flow Log"
  value       = aws_flow_log.main.id
}

#═══════════════════════════════════════════════════════════════
# NETWORK ACLs
#═══════════════════════════════════════════════════════════════

output "network_acls" {
  description = "Network ACL IDs"
  value = {
    public_nacl   = module.network_acls.public_nacl_id
    private_nacl  = module.network_acls.private_nacl_id
    database_nacl = module.network_acls.database_nacl_id
  }
}
