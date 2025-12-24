#!/bin/bash
# Import existing AWS resources to Terraform Cloud state
# Run this locally to resolve "resource already exists" errors

echo "Importing existing AWS resources..."

# Replace these with your actual resource names from AWS console
BUCKET_NAME="your-actual-bucket-name"
LAMBDA_FUNCTION_NAME="your-actual-lambda-function-name"
IAM_ROLE_NAME="your-actual-iam-role-name"
LOG_GROUP_NAME="/aws/lambda/your-actual-lambda-function-name"

# Import S3 bucket
terraform import aws_s3_bucket.upload_bucket $BUCKET_NAME

# Import Lambda function
terraform import aws_lambda_function.s3_processor $LAMBDA_FUNCTION_NAME

# Import IAM role
terraform import aws_iam_role.lambda_execution_role $IAM_ROLE_NAME

# Import CloudWatch log group
terraform import aws_cloudwatch_log_group.lambda_logs $LOG_GROUP_NAME

# Import other resources as needed...

echo "Import complete! Run 'terraform plan' to verify."