# Changelog:
# AWS-16 - IAM roles and policies for DynamoDB SQS Lambda - 2025-01-28

# Lambda Processor Role
resource "aws_iam_role" "lambda_role" {
  name = "techweek-demo-lambda-processor-role"

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
    JiraId    = "AWS-16"
    ManagedBy = "techweek-demo"
  }
}

# Lambda Processor Policy
resource "aws_iam_role_policy" "lambda_policy" {
  name = "techweek-demo-lambda-processor-policy"
  role = aws_iam_role.lambda_role.id

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
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.dynamodb_changes.arn
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage"
        ]
        Resource = aws_sqs_queue.dynamodb_changes_dlq.arn
      }
    ]
  })
}

# Stream Lambda Role
resource "aws_iam_role" "stream_lambda_role" {
  name = "techweek-demo-stream-lambda-role"

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
    JiraId    = "AWS-16"
    ManagedBy = "techweek-demo"
  }
}

# Stream Lambda Policy
resource "aws_iam_role_policy" "stream_lambda_policy" {
  name = "techweek-demo-stream-lambda-policy"
  role = aws_iam_role.stream_lambda_role.id

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
          "dynamodb:DescribeStream",
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:ListStreams"
        ]
        Resource = aws_dynamodb_table.users.stream_arn
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage"
        ]
        Resource = aws_sqs_queue.dynamodb_changes.arn
      }
    ]
  })
}