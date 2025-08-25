# 3-Tier Application Infrastructure with Terraform

> **Quick Start**: See [QUICK_START.md](QUICK_START.md) for immediate deployment steps.
> **Detailed Guide**: See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for comprehensive instructions.

This Terraform project creates a secure 3-tier application infrastructure on AWS with the following architecture:

## Architecture Overview

```
Internet
    |
    v
[Internet Gateway]
    |
    v
[Public Subnet] - Frontend EC2 (Web Server)
    |
    v
[NAT Gateway]
    |
    v
[Private Subnet] - Backend EC2 (Application Server)
    |
    v
[Database Subnets] - RDS MySQL Database
```

## Components

### Tier 1: Frontend (Public Subnet)
- **EC2 Instance**: Hosts the web frontend
- **Access**: Internet accessible on ports 80 (HTTP) and 443 (HTTPS)
- **Security**: Only allows incoming traffic on web ports and SSH
- **Role**: Serves as the entry point and proxy to backend services

### Tier 2: Backend (Private Subnet)
- **EC2 Instance**: Hosts the application backend/API
- **Access**: Only accessible from the frontend instance on ports 80 and 443
- **Security**: Isolated from direct internet access
- **Role**: Processes business logic and communicates with the database

### Tier 3: Database (Private Database Subnets)
- **RDS MySQL**: Managed database service
- **Access**: Only accessible from the backend instance on port 3306
- **Security**: Completely isolated from internet and frontend
- **Role**: Stores and manages application data

## Security Features

1. **Network Isolation**: Each tier is in separate subnets with specific routing
2. **Security Groups**: Restrictive firewall rules allowing only necessary communication
3. **No Direct Database Access**: Database only accessible via backend
4. **NAT Gateway**: Provides internet access for private instances without exposing them
5. **Encrypted Storage**: Database storage is encrypted at rest

## Prerequisites

Before deploying this infrastructure, ensure you have:

1. **AWS CLI configured** with appropriate credentials
2. **Terraform installed** (version >= 1.0)
3. **Appropriate AWS permissions** for creating VPC, EC2, RDS resources

## Deployment Instructions

### 1. Clone and Configure

```bash
# Clone the repository
git clone <your-repo-url>
cd terraform-3tier-app

# Update terraform.tfvars with your specific values
# IMPORTANT: Change the following in terraform.tfvars:
# - db_password: A secure password for your database
# - aws_region: Your preferred AWS region
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Plan the Deployment

```bash
terraform plan
```

Review the plan to ensure all resources look correct.

### 4. Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted to create the resources.

### 5. Access Your Application

After successful deployment, Terraform will output:
- Frontend public IP address
- Application URL
- SSH connection commands

## Testing the Application

1. **Access the Frontend**:
   - Open your browser and navigate to the application URL provided in the output
   - You should see a 3-tier application dashboard

2. **Test Backend Connectivity**:
   - Click the "Test Backend Connection" button on the frontend
   - This tests the communication between frontend and backend

3. **Test Database Connectivity**:
   - Navigate to `http://<frontend-ip>/db-test.php`
   - This tests the connection between backend and database

## File Structure

```
├── main.tf              # Main Terraform configuration
├── variables.tf         # Variable definitions
├── terraform.tfvars     # Variable values (update this!)
├── vpc.tf              # VPC and networking resources
├── security-groups.tf   # Security group definitions
├── ec2.tf              # EC2 instance configurations
├── rds.tf              # RDS database configuration
├── outputs.tf          # Output definitions
├── scripts/
│   ├── frontend-setup.sh  # Frontend initialization script
│   └── backend-setup.sh   # Backend initialization script
└── README.md           # This file
```

## Customization

### Instance Types
Modify `instance_type` and `db_instance_class` in `terraform.tfvars` to use different instance sizes.

### Network Configuration
Update the CIDR blocks in `terraform.tfvars` to use different IP ranges.

### Database Configuration
Change database engine, version, or size by modifying the RDS configuration in `rds.tf`.

## Monitoring and Maintenance

### Viewing Logs
- **Frontend logs**: SSH to frontend and check `/var/log/httpd/`
- **Backend logs**: SSH to backend (via frontend) and check `/var/log/httpd/`
- **Database logs**: Check RDS logs in AWS Console

### Health Checks
- Frontend: `http://<frontend-ip>/health.html`
- Backend: `http://<frontend-ip>/api/` (proxied through frontend)
- Database: `http://<frontend-ip>/db-test.php`

## Security Considerations

1. **SSH Access**: The frontend allows SSH from anywhere (0.0.0.0/0). Consider restricting this to your IP address.
2. **Database Password**: Ensure you use a strong password and consider using AWS Secrets Manager.
3. **SSL/TLS**: Consider adding SSL certificates for production use.
4. **Monitoring**: Set up CloudWatch monitoring and alerting.

## Cleanup

To destroy all resources and avoid charges:

```bash
terraform destroy
```

Type `yes` when prompted to destroy all resources.

## Troubleshooting

### Common Issues

1. **Key Pair Not Found**: Ensure the key pair exists in your specified AWS region
2. **Database Connection Issues**: Check security groups and verify the database is in running state
3. **Instance Not Accessible**: Verify security groups allow the necessary ports

### Getting Help

Check Terraform outputs for connection information:
```bash
terraform output
```

View the current state:
```bash
terraform show
```

## Cost Estimation

This infrastructure uses:
- 2x t3.micro EC2 instances
- 1x db.t3.micro RDS instance
- 1x NAT Gateway
- Standard networking (VPC, subnets, IGW)

Estimated monthly cost: ~$35-50 USD (may vary by region and usage).

## Next Steps

- Add Application Load Balancer for high availability
- Implement Auto Scaling Groups
- Add SSL/TLS certificates
- Set up monitoring and alerting
- Implement backup strategies
- Add CI/CD pipeline for application deployment