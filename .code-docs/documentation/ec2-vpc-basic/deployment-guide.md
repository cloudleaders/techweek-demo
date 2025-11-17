# AWS-13 Deployment Guide

## Prerequisites

### Required Tools
- **Terraform**: >= 1.1
- **AWS CLI**: Configured with appropriate credentials
- **SSH Key Pair**: For EC2 instance access

### AWS Permissions Required
- EC2: Full access for instance management
- VPC: Full access for network configuration
- IAM: Role and policy management
- CloudWatch: Basic monitoring setup

## Step-by-Step Deployment

### 1. Prepare Configuration

```bash
cd iac/terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
aws_region         = "us-east-1"
environment        = "dev"
project_name       = "ec2-vpc-basic"
vpc_cidr          = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
instance_type     = "t3.micro"
key_name          = "your-key-pair-name"
allowed_ssh_cidr  = "your.ip.address/32"  # Restrict to your IP
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Plan Deployment

```bash
terraform plan
```

Review the planned changes before applying.

### 4. Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when prompted to confirm deployment.

### 5. Verify Deployment

After successful deployment, Terraform will output:
- VPC ID and CIDR
- Instance ID and public IP
- SSH connection command

### 6. Connect to Instance

```bash
ssh -i ~/.ssh/your-key.pem ec2-user@<public-ip>
```

## Post-Deployment Verification

### Check Instance Status
```bash
# AWS CLI
aws ec2 describe-instances --instance-ids <instance-id>

# SSH to instance
ssh -i ~/.ssh/your-key.pem ec2-user@<public-ip>
sudo systemctl status amazon-cloudwatch-agent
```

### Verify Network Connectivity
- Instance should have public IP
- Security group should allow SSH (port 22)
- Internet gateway should be attached

## Troubleshooting

### Common Issues

1. **SSH Connection Refused**
   - Check security group rules
   - Verify key pair permissions (chmod 400)
   - Confirm instance is running

2. **Terraform Apply Fails**
   - Check AWS credentials
   - Verify IAM permissions
   - Review error messages in output

3. **Instance Not Accessible**
   - Check route table configuration
   - Verify internet gateway attachment
   - Confirm public IP assignment

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

Type `yes` when prompted to confirm destruction.