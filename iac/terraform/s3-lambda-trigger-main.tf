# Changelog:
# AWS-14 - Initial S3 bucket and Lambda function infrastructure - 2025-01-28

terraform {
  required_version = ">= 1.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# S3 bucket for file uploads
resource "aws_s3_bucket" "upload_bucket" {
  bucket = "${var.project_name}-${var.environment}-upload-bucket"

  tags = {
    Name        = "${var.project_name}-upload-bucket"
    Environment = var.environment
    JiraId      = "AWS-14"
    ManagedBy   = "terraform"
  }
}

# S3 bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "upload_bucket_encryption" {
  bucket = aws_s3_bucket.upload_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "upload_bucket_pab" {
  bucket = aws_s3_bucket.upload_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM role for Lambda function
resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.project_name}-${var.environment}-lambda-role"

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
    Name        = "${var.project_name}-lambda-role"
    Environment = var.environment
    JiraId      = "AWS-14"
    ManagedBy   = "terraform"
  }
}

# IAM policy for Lambda to access S3 and CloudWatch
resource "aws_iam_role_policy" "s3_lambda_policy" {
  name = "${var.project_name}-${var.environment}-s3-lambda-policy"
  role = aws_iam_role.lambda_execution_role.id

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
        Resource = "arn:aws:logs:${var.aws_region}:*:log-group:/aws/lambda/${var.project_name}-${var.environment}-s3-processor*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "${aws_s3_bucket.upload_bucket.arn}/*"
      }
    ]
  })
}

# CloudWatch log group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}-s3-processor"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-lambda-logs"
    Environment = var.environment
    JiraId      = "AWS-14"
    ManagedBy   = "terraform"
  }
}

# Lambda function
resource "aws_lambda_function" "s3_processor" {
  filename         = "lambda_function.zip"
  function_name    = "${var.project_name}-${var.environment}-s3-processor"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "lambda_handler.lambda_handler"
  runtime         = "python3.12"
  timeout         = 30
  source_code_hash = filebase64sha256("lambda_function.zip")

  depends_on = [
    aws_iam_role_policy.s3_lambda_policy,
    aws_cloudwatch_log_group.lambda_logs,
  ]

  tags = {
    Name        = "${var.project_name}-s3-processor"
    Environment = var.environment
    JiraId      = "AWS-14"
    ManagedBy   = "terraform"
  }
}

# S3 bucket notification to trigger Lambda
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.upload_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_processor.arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

# Lambda permission for S3 to invoke the function
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.upload_bucket.arn
}