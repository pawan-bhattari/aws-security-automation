# AWS Provider Configuration
# This tells Terraform how to authenticate with AWS

provider "aws" {
  region = var.aws_region

  # Default tags applied to all resources
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Project     = "AWS-Security-Project4"
      Environment = "Production"
      CreatedBy   = "Davi Lal"
    }
  }
}

# Additional provider for Management Account (if needed)
provider "aws" {
  alias  = "management"
  region = var.aws_region

  # Assume role in management account
  assume_role {
    role_arn = "arn:aws:iam::${var.management_account_id}:role/OrganizationAccountAccessRole"
  }
}
