# Changelog:
# AWS-14 - Outputs for S3 Lambda trigger - 2025-01-27

output "upload_bucket_name" {
  description = "Name of the S3 upload bucket"
  value       = aws_s3_bucket.upload_bucket.bucket
}

output "upload_bucket_arn" {
  description = "ARN of the S3 upload bucket"
  value       = aws_s3_bucket.upload_bucket.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.file_processor.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.file_processor.arn
}