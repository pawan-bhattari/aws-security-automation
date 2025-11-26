# terraform.tfvars
# Terraform Variable Values - AWS Organization Configuration
# ⚠️ DO NOT commit this file to Git! Contains sensitive account IDs

# ============================================================================
# AWS ORGANIZATION ACCOUNT IDs
# ============================================================================

# Management Account (Root Organization Account)
# Email: davi.lal4094@gmail.com
# Status: Active ✅
management_account_id = "667902537866"

# Security Account (OU: Security)
# Email: diyaracreek@gmail.com
# Status: Active ✅
security_account_id = "370200342575"

# Development Account (OU: Workloads)
# Email: davi.lal4094+dev@gmail.com
# Status: Active ✅
dev_account_id = "023886152880"

# ============================================================================
# REGIONAL CONFIGURATION
# ============================================================================
prod_account_id = "842983351081"

# Primary AWS Region - Sydney, Australia
aws_region = "ap-southeast-2"

# ============================================================================
# PROJECT METADATA
# ============================================================================

# Environment classification
environment = "security"

# Project name for resource tagging and naming
project_name = "security-automation"
