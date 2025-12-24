# Changelog:
# AWS-14 - Output definitions for S3 Lambda trigger resources - 2025-01-28

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.upload_bucket.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.upload_bucket.arn
}

output "s3_lambda_function_name" {
  description = "Name of the S3 Lambda function"
  value       = aws_lambda_function.s3_processor.function_name
}

output "s3_lambda_function_arn" {
  description = "ARN of the S3 Lambda function"
  value       = aws_lambda_function.s3_processor.arn
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group for Lambda"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}