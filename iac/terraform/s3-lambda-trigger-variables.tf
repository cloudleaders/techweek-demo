# Changelog:
# AWS-14 - Initial variable definitions for S3 Lambda trigger - 2025-01-28

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "s3-lambda-trigger"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}