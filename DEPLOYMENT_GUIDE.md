# 3-Tier Application Deployment Guide

Follow these steps to deploy your 3-tier application infrastructure on AWS.

## Prerequisites Checklist

Before starting, ensure you have:

### 1. AWS Account Setup
- [ ] Active AWS account with billing enabled
- [ ] AWS CLI installed and configured
- [ ] Appropriate IAM permissions for creating VPC, EC2, RDS resources

### 2. Tools Installation
- [ ] Terraform installed (version >= 1.0)
- [ ] Git installed (if cloning from repository)

## Step-by-Step Deployment

### Step 1: Verify AWS Configuration

```bash
# Check if AWS CLI is configured
aws sts get-caller-identity

# This should return your AWS account details
# If not configured, run: aws configure
```

### Step 2: Install Terraform (if not already installed)

**On macOS:**
```bash
brew install terraform
```

**On Ubuntu/Debian:**
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

**On Windows:**
Download from: https://www.terraform.io/downloads

### Step 3: Configure Your Variables

Edit the `terraform.tfvars` file:

```bash
# Open the file in your preferred editor
nano terraform.tfvars
# or
vim terraform.tfvars
```

**IMPORTANT**: Update these values:
- `db_password`: A strong, secure password
- `aws_region`: Your preferred AWS region

### Step 4: Initialize Terraform

```bash
# Initialize Terraform (downloads required providers)
terraform init
```

Expected output:
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.x.x...
Terraform has been successfully initialized!
```

### Step 5: Validate Configuration

```bash
# Check for syntax errors
terraform validate
```

Expected output:
```
Success! The configuration is valid.
```

### Step 6: Plan the Deployment

```bash
# See what resources will be created
terraform plan
```

Review the output carefully. You should see:
- 1 VPC
- 4 Subnets (public, private, 2 database)
- 1 Internet Gateway
- 1 NAT Gateway
- 3 Route Tables
- 3 Security Groups
- 2 EC2 Instances
- 1 RDS Instance
- Various supporting resources

### Step 7: Deploy the Infrastructure

```bash
# Apply the configuration
terraform apply
```

When prompted, type `yes` to confirm.

**Deployment time**: Approximately 10-15 minutes (RDS takes the longest)

### Step 8: Verify Deployment

After successful deployment, Terraform will output important information:

```bash
# View all outputs
terraform output
```

You should see:
- Frontend public IP
- Application URL
- Generated private key file path
- SSH commands
- Database endpoint

### Step 9: Test Your Application

1. **Access the Frontend**:
   ```bash
   # Get the application URL
   terraform output application_url
   
   # Open in browser or test with curl
   curl http://YOUR_FRONTEND_IP
   ```

2. **Test Backend Connection**:
   - Open the application URL in your browser
   - Click "Test Backend Connection" button
   - Should show "✅ Backend connection successful!"

3. **Test Database Connection**:
   ```bash
   # Test database connectivity
   curl http://YOUR_FRONTEND_IP/db-test.php
   ```

### Step 10: SSH Access (Optional)

**Connect to Frontend**:
```bash
# Use the SSH command from terraform output
terraform output ssh_command_frontend
```

**Connect to Backend (via Frontend)**:
```bash
# Use the SSH command from terraform output
terraform output ssh_command_backend
```

## Troubleshooting Common Issues

### Issue 1: Key Pair Not Found
**Error**: `InvalidKeyPair.NotFound`
**Solution**: This shouldn't happen as the key pair is auto-generated. If it does, run `terraform destroy` and `terraform apply` again.

### Issue 2: Insufficient Permissions
**Error**: `UnauthorizedOperation`
**Solution**: Check your AWS IAM permissions include:
- EC2 full access
- VPC full access
- RDS full access

### Issue 3: Database Connection Failed
**Error**: Backend can't connect to database
**Solution**: 
1. Wait 5-10 minutes for RDS to fully initialize
2. Check security groups allow port 3306
3. Verify database endpoint in outputs

### Issue 4: Frontend Not Accessible
**Error**: Can't access application URL
**Solution**:
1. Check security group allows ports 80/443
2. Verify EC2 instance is running
3. Check if Apache service started (SSH and run `sudo systemctl status httpd`)

## Monitoring Your Application

### Health Check URLs
- Frontend: `http://YOUR_IP/health.html`
- Backend API: `http://YOUR_IP/api/`
- Database Test: `http://YOUR_IP/db-test.php`
- Sample Data: `http://YOUR_IP/api/users.php`

### AWS Console Monitoring
1. EC2 Dashboard - Monitor instance health
2. RDS Dashboard - Monitor database performance
3. VPC Dashboard - Monitor network traffic
4. CloudWatch - View logs and metrics

## Cost Management

**Estimated Monthly Cost**: ~$35-50 USD

**Cost Breakdown**:
- 2x t3.micro EC2: ~$15/month
- 1x db.t3.micro RDS: ~$15/month
- NAT Gateway: ~$15/month
- Storage & Data Transfer: ~$5/month

**Cost Optimization Tips**:
- Stop instances when not needed (development)
- Use Reserved Instances for production
- Monitor data transfer costs

## Cleanup (When Done Testing)

**WARNING**: This will destroy ALL resources and data!

```bash
# Destroy all resources
terraform destroy
```

Type `yes` when prompted.

## Next Steps for Production

1. **Security Enhancements**:
   - Restrict SSH access to your IP only
   - Add SSL/TLS certificates
   - Use AWS Secrets Manager for database passwords

2. **High Availability**:
   - Add Application Load Balancer
   - Implement Auto Scaling Groups
   - Multi-AZ RDS deployment

3. **Monitoring & Logging**:
   - Set up CloudWatch alarms
   - Configure log aggregation
   - Implement health checks

4. **Backup & Recovery**:
   - Enable automated RDS backups
   - Create AMI snapshots
   - Document recovery procedures

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review Terraform logs: `terraform apply -auto-approve -no-color 2>&1 | tee terraform.log`
3. Check AWS CloudTrail for API errors
4. Verify your AWS service limits

Remember to always test in a development environment before deploying to production!