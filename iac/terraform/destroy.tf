# Destroy Configuration
# This file triggers destruction of all AWS-14 and AWS-16 resources
# Changelog:
# AWS-14, AWS-16 - Destroy all resources for cleanup - 2025-01-28

# Set destroy flag for all resources
locals {
  destroy_resources = true
}

# Conditional resource creation (all set to false for destruction)
resource "null_resource" "destroy_trigger" {
  count = local.destroy_resources ? 0 : 1
  
  triggers = {
    destroy_time = timestamp()
  }
}