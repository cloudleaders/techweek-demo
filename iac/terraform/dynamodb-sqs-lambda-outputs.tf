# Changelog:
# AWS-16 - Initial outputs for DynamoDB SQS Lambda - 2025-01-28

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.users.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.users.arn
}

output "sqs_queue_url" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.dynamodb_changes.url
}

output "lambda_function_name" {
  description = "Name of the Lambda processor function"
  value       = aws_lambda_function.processor.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda processor function"
  value       = aws_lambda_function.processor.arn
}