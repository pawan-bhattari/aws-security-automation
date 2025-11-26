# IAM Module Outputs

output "ec2_instance_profile_name" {
  description = "Name of EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_s3_readonly.name
}

output "ec2_role_arn" {
  description = "ARN of EC2 IAM role"
  value       = aws_iam_role.ec2_s3_readonly.arn
}

output "lambda_role_arn" {
  description = "ARN of Lambda execution role"
  value       = aws_iam_role.lambda_execution.arn
}
