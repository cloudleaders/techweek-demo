# Changelog:
# AWS-14 - Initial S3 bucket and Lambda function for file processing - 2025-01-27
# AWS-14 - Removed S3 bucket versioning per user request - 2025-01-27

# S3 Bucket for file uploads
resource "aws_s3_bucket" "file_processor_bucket" {
  bucket = "${var.project_name}-file-processor-${var.environment}"

  tags = {
    Name        = "${var.project_name}-file-processor-bucket"
    Environment = var.environment
    JiraId      = "AWS-14"
    ManagedBy   = "terraform"
  }
}

# S3 Bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "file_processor_encryption" {
  bucket = aws_s3_bucket.file_processor_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# IAM Role for Lambda function
resource "aws_iam_role" "file_processor_lambda_role" {
  name = "${var.project_name}-file-processor-lambda-role"

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
    Name        = "${var.project_name}-file-processor-lambda-role"
    Environment = var.environment
    JiraId      = "AWS-14"
    ManagedBy   = "terraform"
  }
}

# IAM Policy for Lambda function
resource "aws_iam_role_policy" "file_processor_lambda_policy" {
  name = "${var.project_name}-file-processor-lambda-policy"
  role = aws_iam_role.file_processor_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "${aws_s3_bucket.file_processor_bucket.arn}/*"
      }
    ]
  })
}

# Lambda function
resource "aws_lambda_function" "file_processor" {
  filename      = "lambda-file-processor.zip"
  function_name = "${var.project_name}-file-processor"
  role          = aws_iam_role.file_processor_lambda_role.arn
  handler       = "lambda_handler.lambda_handler"
  runtime       = "python3.11"
  timeout       = 30
  memory_size   = 256

  tags = {
    Name        = "${var.project_name}-file-processor"
    Environment = var.environment
    JiraId      = "AWS-14"
    ManagedBy   = "terraform"
  }
}

# Lambda permission for S3 to invoke function
resource "aws_lambda_permission" "s3_invoke_lambda" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.file_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.file_processor_bucket.arn
}

# S3 bucket notification
resource "aws_s3_bucket_notification" "file_processor_notification" {
  bucket = aws_s3_bucket.file_processor_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.file_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.s3_invoke_lambda]
}