# backend.tf - Terraform Remote State Configuration
# Region: ap-southeast-2 (Sydney)
# Account: 3702003456456
terraform {
  backend "s3" {
    bucket         = ""
    key            = ""
    region         = ""
    encrypt        = true
    dynamodb_table = ""
  }

  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
