# AWS-14 File Processor Deployment Guide

## Prerequisites

### 1. AWS Credentials Configuration
Configure AWS credentials using one of these methods:

**Option A: AWS CLI**
```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, Region, and Output format
```

**Option B: Environment Variables**
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### 2. Required AWS Permissions
Your AWS credentials need the following permissions:
- S3: CreateBucket, PutBucketNotification, PutBucketEncryption
- Lambda: CreateFunction, UpdateFunctionCode, AddPermission
- IAM: CreateRole, AttachRolePolicy, CreatePolicy
- CloudWatch: CreateLogGroup (automatic)

## Deployment Steps

### Step 1: Navigate to Terraform Directory
```bash
cd iac/terraform
```

### Step 2: Set Required Variables
Create or update `terraform.tfvars`:
```hcl
project_name = "techweek-demo"
environment = "dev"
aws_region = "us-east-1"
```

### Step 3: Plan Deployment
```bash
terraform plan
```

### Step 4: Deploy Infrastructure
```bash
terraform apply
```
Type `yes` when prompted to confirm deployment.

### Step 5: Verify Deployment
```bash
terraform output
```

## Testing the Deployment

### 1. Upload Test File
```bash
aws s3 cp test-file.txt s3://your-bucket-name/
```

### 2. Check Lambda Execution
```bash
aws logs tail /aws/lambda/techweek-demo-file-processor --follow
```

## Cleanup

To remove all deployed resources:
```bash
terraform destroy
```