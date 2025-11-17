# AWS-13 Troubleshooting Guide

## Common Issues and Solutions

### 1. Terraform Issues

#### Backend Configuration Error
**Problem**: Terraform backend not configured properly
**Solution**: 
- Update `iac/terraform/backend.tf` with correct organization and workspace
- Run `terraform init` to reinitialize

#### Provider Version Conflicts
**Problem**: AWS provider version mismatch
**Solution**:
```bash
terraform init -upgrade
```

#### State Lock Issues
**Problem**: Terraform state locked
**Solution**:
- Wait for other operations to complete
- Force unlock if necessary: `terraform force-unlock <lock-id>`

### 2. AWS Connectivity Issues

#### SSH Connection Refused
**Problem**: Cannot SSH to EC2 instance
**Diagnosis**:
```bash
# Check instance status
aws ec2 describe-instances --instance-ids <instance-id>

# Check security group rules
aws ec2 describe-security-groups --group-ids <sg-id>
```

**Solutions**:
- Verify security group allows SSH (port 22) from your IP
- Check key pair permissions: `chmod 400 ~/.ssh/your-key.pem`
- Ensure instance is in running state
- Verify public IP assignment

#### No Internet Access from Instance
**Problem**: Instance cannot reach internet
**Diagnosis**:
```bash
# SSH to instance and test
ping 8.8.8.8
curl -I http://google.com
```

**Solutions**:
- Check route table has route to internet gateway (0.0.0.0/0 -> igw-xxx)
- Verify internet gateway is attached to VPC
- Confirm subnet is associated with correct route table

### 3. Security Issues

#### Key Pair Not Found
**Problem**: AWS key pair doesn't exist
**Solution**:
- Create key pair in AWS console or CLI
- Update `key_name` variable in terraform.tfvars
- Ensure public key file exists at specified path

#### Permission Denied (SSH)
**Problem**: SSH key permissions incorrect
**Solution**:
```bash
chmod 400 ~/.ssh/your-key.pem
ssh -i ~/.ssh/your-key.pem ec2-user@<public-ip>
```

### 4. Resource Limits

#### Instance Launch Failed
**Problem**: Cannot launch t3.micro instance
**Possible Causes**:
- AWS account limits reached
- Insufficient capacity in availability zone
- Service limits exceeded

**Solutions**:
- Try different availability zone
- Request limit increase from AWS support
- Use different instance type temporarily

### 5. Monitoring Issues

#### CloudWatch Agent Not Running
**Problem**: CloudWatch monitoring not working
**Diagnosis**:
```bash
# SSH to instance
sudo systemctl status amazon-cloudwatch-agent
```

**Solution**:
```bash
# Restart CloudWatch agent
sudo systemctl restart amazon-cloudwatch-agent
sudo systemctl enable amazon-cloudwatch-agent
```

## Diagnostic Commands

### Terraform Diagnostics
```bash
# Check configuration
terraform validate

# Show current state
terraform show

# List resources
terraform state list

# Show specific resource
terraform state show aws_instance.main
```

### AWS CLI Diagnostics
```bash
# Check VPC
aws ec2 describe-vpcs --vpc-ids <vpc-id>

# Check subnets
aws ec2 describe-subnets --subnet-ids <subnet-id>

# Check route tables
aws ec2 describe-route-tables --route-table-ids <rt-id>

# Check security groups
aws ec2 describe-security-groups --group-ids <sg-id>

# Check instance
aws ec2 describe-instances --instance-ids <instance-id>
```

### Network Connectivity Tests
```bash
# Test from local machine
ping <public-ip>
telnet <public-ip> 22

# Test from instance (after SSH)
ping 8.8.8.8
curl -I http://google.com
nslookup google.com
```

## Getting Help

### Log Files
- **Terraform**: Check terraform output and error messages
- **CloudWatch**: Check CloudWatch Logs for instance logs
- **Instance**: SSH to instance and check `/var/log/messages`

### AWS Support
- Use AWS Support Center for account-specific issues
- Check AWS Service Health Dashboard for service outages
- Review AWS documentation for service limits

### Community Resources
- Terraform AWS Provider documentation
- AWS EC2 troubleshooting guides
- Stack Overflow for specific error messages