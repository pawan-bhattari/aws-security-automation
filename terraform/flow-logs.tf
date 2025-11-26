
# VPC FLOW LOGS INFRASTRUCTURE


data "aws_caller_identity" "current" {}


resource "aws_s3_bucket" "flow_logs" {
  bucket = "security-automation-flow-logs-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "security-automation-flow-logs"
    Purpose     = "Store VPC Flow Logs for threat detection"
    Retention   = "90-days"
    Environment = "security"
    Project     = "AWS-Security-Lab"
    Owner       = "Bhattari"
  }
}

resource "aws_s3_bucket_versioning" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    filter {}

    expiration {
      days = 90
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_policy" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSLogDeliveryWrite"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.flow_logs.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Sid    = "AWSLogDeliveryAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.flow_logs.arn
      }
    ]
  })
}

#═══════════════════════════════════════════════════════════════
# VPC FLOW LOG
#═══════════════════════════════════════════════════════════════

resource "aws_flow_log" "main" {
  vpc_id = module.vpc.vpc_id

  log_destination      = aws_s3_bucket.flow_logs.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"

  log_format = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status}"

  tags = {
    Name        = "security-automation-vpc-flow-log"
    Environment = "security"
    Owner       = "Bhattari"
  }

  depends_on = [aws_s3_bucket_policy.flow_logs]
}

#═══════════════════════════════════════════════════════════════
# ATHENA QUERY RESULTS BUCKET
#═══════════════════════════════════════════════════════════════

resource "aws_s3_bucket" "athena_results" {
  bucket = "security-automation-athena-results-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "athena-query-results"
    Purpose     = "Store Athena query results"
    Environment = "security"
    Owner       = "Bhattari"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAthenaAccess"
        Effect = "Allow"
        Principal = {
          Service = "athena.amazonaws.com"
        }
        Action = [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.athena_results.arn,
          "${aws_s3_bucket.athena_results.arn}/*"
        ]
      },
      {
        Sid    = "AllowUserAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.athena_results.arn,
          "${aws_s3_bucket.athena_results.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket_policy.athena_results]
}

resource "aws_s3_bucket_lifecycle_configuration" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id

  rule {
    id     = "delete-old-results"
    status = "Enabled"

    filter {}

    expiration {
      days = 30
    }
  }
}


# ATHENA WORKGROUP (Database created manually)


resource "aws_athena_workgroup" "security" {
  name = ""

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.id}/queries/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }

    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
    bytes_scanned_cutoff_per_query     = 10737418240
  }

  tags = {
    Name = "security-automation-workgroup"
  }

  depends_on = [
    aws_s3_bucket.athena_results,
    aws_s3_bucket_policy.athena_results
  ]
}

#═══════════════════════════════════════════════════════════════
# AUTO-GENERATE ATHENA SQL
#═══════════════════════════════════════════════════════════════

resource "local_file" "athena_create_table_sql" {
  filename = "${path.module}/../queries/create_flow_logs_table.sql"

  content = <<-SQL
-- VPC Flow Logs Athena Table Definition
-- Auto-generated by Terraform
-- Account: ${data.aws_caller_identity.current.account_id}
-- Region: 

CREATE DATABASE IF NOT EXISTS vpc_flow_logs_db;

CREATE EXTERNAL TABLE IF NOT EXISTS vpc_flow_logs_db.flow_logs (
  version int,
  account_id string,
  interface_id string,
  srcaddr string,
  dstaddr string,
  srcport int,
  dstport int,
  protocol int,
  packets bigint,
  bytes bigint,
  start_time bigint,
  end_time bigint,
  action string,
  log_status string
)
PARTITIONED BY (
  year string,
  month string,
  day string
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ' '
LOCATION ''
TBLPROPERTIES (
  "skip.header.line.count"="0",
  "projection.enabled"="true",
  "projection.year.type"="integer",
  "projection.year.range"="2024,2030",
  "projection.month.type"="integer",
  "projection.month.range"="1,12",
  "projection.month.digits"="2",
  "projection.day.type"="integer",
  "projection.day.range"="1,31",
  "projection.day.digits"="2",
  ""
);
SQL
}

#═══════════════════════════════════════════════════════════════
# OUTPUTS
#═══════════════════════════════════════════════════════════════

output "flow_logs_bucket_name" {
  description = "S3 bucket for VPC Flow Logs"
  value       = aws_s3_bucket.flow_logs.id
}

output "athena_results_bucket" {
  description = "S3 bucket for Athena query results"
  value       = "s3://${aws_s3_bucket.athena_results.id}/"
}

output "athena_workgroup" {
  description = "Athena workgroup name"
  value       = aws_athena_workgroup.security.name
}

output "athena_sql_file" {
  description = "Auto-generated SQL file location"
  value       = "queries/create_flow_logs_table.sql"
}

output "athena_database_note" {
  description = "Athena database was created manually"
  value       = "Database 'vpc_flow_logs_db' created manually via AWS CLI"
}
