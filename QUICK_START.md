# Quick Start Guide

## 1. Clone Repository
```bash
git clone <your-repo-url>
cd terraform-3tier-app
```

## 2. Setup Configuration
```bash
# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

**IMPORTANT**: Update these in terraform.tfvars:
- `key_pair_name`: Your AWS key pair name
- `db_password`: A secure password
- `aws_region`: Your preferred region

## 3. Deploy
```bash
# Initialize
terraform init

# Plan (optional)
terraform plan

# Deploy
terraform apply
```

## 4. Access Application
After deployment, get the URL:
```bash
terraform output application_url
```

## 5. Cleanup (when done)
```bash
terraform destroy
```

## Need Help?
Check `DEPLOYMENT_GUIDE.md` for detailed instructions.