# AWS-14 File Processor Implementation

## Overview

Event-driven serverless architecture that automatically processes files uploaded to an S3 bucket using AWS Lambda.

## Architecture

- **S3 Bucket**: Encrypted storage with event notifications
- **Lambda Function**: Python 3.11 function triggered by S3 events
- **IAM Roles**: Least privilege access for Lambda execution
- **CloudWatch**: Logging and monitoring

## Quick Start

1. **Configure AWS credentials**
2. **Deploy infrastructure**: `terraform apply` in `iac/terraform/`
3. **Test**: Upload files to S3 bucket
4. **Monitor**: Check CloudWatch logs

## Files Generated

### Infrastructure (Terraform)
- `file-processor-main.tf` - Main resources
- `file-processor-variables.tf` - Input variables
- `file-processor-outputs.tf` - Output values

### Application Code
- `src/lambda-file-processor/lambda_handler.py` - Main Lambda function
- `src/lambda-file-processor/requirements.txt` - Dependencies

### Tests
- `tests/file-processor/test_lambda_handler.py` - Unit tests

## Features

- **Event-Driven**: Automatic processing on file upload
- **Secure**: IAM least privilege + S3 encryption
- **Monitored**: CloudWatch logging enabled
- **Tested**: Comprehensive unit test coverage
- **Validated**: File type checking and error handling

## Deployment

See [deployment-guide.md](deployment-guide.md) for detailed deployment instructions.