# Changelog:
# AWS-16 - Data sources for Lambda deployment packages - 2025-01-28

# Lambda processor package
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../src/lambda-python-dynamodb-sqs-lambda"
  output_path = "${path.module}/lambda_function.zip"
  excludes    = ["*.git*", "*.md", "tests/*", "__pycache__/*"]
}

# Stream processor package
data "archive_file" "stream_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../src/lambda-python-dynamodb-sqs-lambda"
  output_path = "${path.module}/stream_lambda.zip"
  excludes    = ["*.git*", "*.md", "tests/*", "__pycache__/*", "lambda_handler.py"]
}