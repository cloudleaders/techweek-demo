# Changelog:
# AWS-16 - Initial DynamoDB, SQS, Lambda integration - 2025-01-28

# DynamoDB Table with Streams
resource "aws_dynamodb_table" "users" {
  name           = "techweek-demo-users"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "id"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    JiraId    = "AWS-16"
    ManagedBy = "techweek-demo"
  }
}

# SQS Queue
resource "aws_sqs_queue" "dynamodb_changes" {
  name                      = "techweek-demo-dynamodb-changes"
  message_retention_seconds = 1209600
  visibility_timeout_seconds = 300

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dynamodb_changes_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    JiraId    = "AWS-16"
    ManagedBy = "techweek-demo"
  }
}

# SQS Dead Letter Queue
resource "aws_sqs_queue" "dynamodb_changes_dlq" {
  name = "techweek-demo-dynamodb-changes-dlq"

  tags = {
    JiraId    = "AWS-16"
    ManagedBy = "techweek-demo"
  }
}

# Lambda Function
resource "aws_lambda_function" "processor" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "techweek-demo-processor"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_handler.lambda_handler"
  runtime         = "python3.12"
  timeout         = 60
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  dead_letter_config {
    target_arn = aws_sqs_queue.dynamodb_changes_dlq.arn
  }

  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.dynamodb_changes.url
    }
  }

  tags = {
    JiraId    = "AWS-16"
    ManagedBy = "techweek-demo"
  }
}

# Lambda Event Source Mapping for SQS
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.dynamodb_changes.arn
  function_name    = aws_lambda_function.processor.arn
  batch_size       = 10
  maximum_batching_window_in_seconds = 5
}

# DynamoDB Stream to SQS (requires Lambda function for integration)
resource "aws_lambda_function" "stream_processor" {
  filename         = data.archive_file.stream_lambda_zip.output_path
  function_name    = "techweek-demo-stream-processor"
  role            = aws_iam_role.stream_lambda_role.arn
  handler         = "stream_handler.lambda_handler"
  runtime         = "python3.12"
  timeout         = 60
  source_code_hash = data.archive_file.stream_lambda_zip.output_base64sha256

  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.dynamodb_changes.url
    }
  }

  tags = {
    JiraId    = "AWS-16"
    ManagedBy = "techweek-demo"
  }
}

# DynamoDB Stream Event Source Mapping
resource "aws_lambda_event_source_mapping" "dynamodb_stream" {
  event_source_arn  = aws_dynamodb_table.users.stream_arn
  function_name     = aws_lambda_function.stream_processor.arn
  starting_position = "LATEST"
  batch_size        = 10
}