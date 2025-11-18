# Changelog:
# AWS-14 - Variables for file processor infrastructure - 2025-01-27

variable "file_processor_lambda_memory" {
  description = "Memory allocation for file processor Lambda function"
  type        = number
  default     = 256
}

variable "file_processor_lambda_timeout" {
  description = "Timeout for file processor Lambda function"
  type        = number
  default     = 30
}