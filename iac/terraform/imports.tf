# Import Configuration for Existing Resources
# Changelog:
# AWS-14 - Import existing resources to avoid conflicts - 2025-01-28

# Import existing S3 bucket
import {
  to = aws_s3_bucket.upload_bucket
  id = "techweek-demo-dev-upload-bucket"  # Replace with actual bucket name
}

# Import existing Lambda function
import {
  to = aws_lambda_function.s3_processor
  id = "techweek-demo-dev-s3-processor"  # Replace with actual function name
}

# Import existing IAM role
import {
  to = aws_iam_role.lambda_execution_role
  id = "techweek-demo-dev-lambda-role"  # Replace with actual role name
}

# Import existing CloudWatch log group
import {
  to = aws_cloudwatch_log_group.lambda_logs
  id = "/aws/lambda/techweek-demo-dev-s3-processor"  # Replace with actual log group name
}