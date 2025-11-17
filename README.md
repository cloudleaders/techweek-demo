# AWS EC2 VPC Basic Infrastructure

## Overview

This project implements **AWS-13 - Create an EC2 instance in a VPC** using Terraform Infrastructure as Code.

## Architecture

- **VPC**: Custom VPC with 10.0.0.0/16 CIDR
- **Subnet**: Public subnet (10.0.1.0/24) with internet access
- **EC2**: t3.micro instance with Amazon Linux 2
- **Security**: Security group with SSH access
- **Monitoring**: CloudWatch monitoring enabled

## Quick Start

### Prerequisites
- AWS CLI configured
- Terraform >= 1.1 installed
- SSH key pair available

### Deployment

1. **Configure variables**:
   ```bash
   cd iac/terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

2. **Deploy infrastructure**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. **Connect to instance**:
   ```bash
   # Use the SSH command from terraform output
   ssh -i ~/.ssh/your-key.pem ec2-user@<public-ip>
   ```

## Configuration

Key variables in `terraform.tfvars`:
- `aws_region`: AWS region (default: us-east-1)
- `instance_type`: EC2 instance type (default: t3.micro)
- `key_name`: SSH key pair name
- `allowed_ssh_cidr`: CIDR for SSH access (restrict for security)

## Security

- EBS volumes encrypted
- Security group restricts access to SSH only
- IAM role with least privilege
- CloudWatch monitoring enabled

## Cost Optimization

- t3.micro instance (AWS Free Tier eligible)
- gp3 EBS storage (cost-effective)
- Single AZ deployment for demo

## Cleanup

```bash
terraform destroy
```

## Support

For issues related to AWS-13, refer to the JIRA ticket or project documentation.