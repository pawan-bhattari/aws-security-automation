# IAM Module
# Creates IAM roles for EC2 instances (similar to Project 3)

# IAM Role for EC2 instances to access S3
resource "aws_iam_role" "ec2_s3_readonly" {
  name = "${var.project_name}-ec2-s3-readonly-role"

  # Trust policy - who can assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-s3-readonly-role"
  }
}

# Attach AWS managed policy for S3 read-only access
resource "aws_iam_role_policy_attachment" "s3_readonly" {
  role       = aws_iam_role.ec2_s3_readonly.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Instance profile (wrapper for the role)
resource "aws_iam_instance_profile" "ec2_s3_readonly" {
  name = "${var.project_name}-ec2-s3-readonly-profile"
  role = aws_iam_role.ec2_s3_readonly.name

  tags = {
    Name = "${var.project_name}-ec2-s3-readonly-profile"
  }
}

# IAM Role for Lambda functions
resource "aws_iam_role" "lambda_execution" {
  name = "${var.project_name}-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-lambda-execution-role"
  }
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom policy for Lambda security functions
resource "aws_iam_policy" "lambda_security" {
  name        = "${var.project_name}-lambda-security-policy"
  description = "Policy for Lambda security automation functions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutEncryptionConfiguration",
          "s3:PutBucketTagging",
          "s3:GetBucketEncryption",
          "s3:GetBucketTagging"
        ]
        Resource = "arn:aws:s3:::*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeSecurityGroups",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:CreateTags",
          "ec2:DescribeInstances",
          "ec2:StopInstances"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudtrail:DescribeTrails",
          "cloudtrail:GetTrailStatus",
          "cloudtrail:StartLogging"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-lambda-security-policy"
  }
}

# Attach custom policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_security" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.lambda_security.arn
}
