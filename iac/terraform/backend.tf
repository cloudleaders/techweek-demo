# Terraform Backend Configuration
# Changelog:
# AWS-14 - Initial backend configuration for state management - 2025-01-28

terraform {
  cloud {
    organization = "aws-devops-ai"
    workspaces {
      name = "aws-cloudleader-demo"
    }
  }
}