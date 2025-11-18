# Changelog:
# AWS-14 - Outputs for file processor infrastructure - 2025-01-27

output "file_processor_bucket_name" {
  description = "Name of the S3 bucket for file processing"
  value       = aws_s3_bucket.file_processor_bucket.bucket
}

output "file_processor_bucket_arn" {
  description = "ARN of the S3 bucket for file processing"
  value       = aws_s3_bucket.file_processor_bucket.arn
}

output "file_processor_lambda_function_name" {
  description = "Name of the file processor Lambda function"
  value       = aws_lambda_function.file_processor.function_name
}

output "file_processor_lambda_function_arn" {
  description = "ARN of the file processor Lambda function"
  value       = aws_lambda_function.file_processor.arn
}