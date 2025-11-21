# Changelog:
# AWS-14 - Initial S3 bucket and Lambda trigger creation - 2025-01-27

resource "aws_s3_bucket" "upload_bucket" {
  bucket = "${var.project_name}-upload-bucket-${random_id.bucket_suffix.hex}"
  tags = {
    Name = "${var.project_name}-upload-bucket"
    Environment = var.environment
    JiraId = "AWS-14"
    ManagedBy = "terraform"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_server_side_encryption_configuration" "upload_bucket_encryption" {
  bucket = aws_s3_bucket.upload_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "upload_bucket_pab" {
  bucket = aws_s3_bucket.upload_bucket.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_lambda_function" "file_processor" {
  filename = data.archive_file.lambda_zip.output_path
  function_name = "${var.project_name}-file-processor"
  role = aws_iam_role.lambda_execution_role.arn
  handler = "lambda_handler.lambda_handler"
  runtime = "python3.11"
  timeout = 30
  memory_size = 128
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  tags = {
    Name = "${var.project_name}-file-processor"
    Environment = var.environment
    JiraId = "AWS-14"
    ManagedBy = "terraform"
  }
}

data "archive_file" "lambda_zip" {
  type = "zip"
  output_path = "${path.module}/lambda_function.zip"
  source_dir = "${path.root}/../src/lambda-s3-lambda-trigger"
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.project_name}-lambda-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
  tags = {
    Name = "${var.project_name}-lambda-execution-role"
    Environment = var.environment
    JiraId = "AWS-14"
    ManagedBy = "terraform"
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:GetObjectVersion"]
        Resource = "${aws_s3_bucket.upload_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.upload_bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.file_processor.arn
    events = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id = "AllowExecutionFromS3Bucket"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.file_processor.function_name
  principal = "s3.amazonaws.com"
  source_arn = aws_s3_bucket.upload_bucket.arn
}