# Flask API Deployment on AWS EC2 Quick Start Guide

## Prerequisites

- AWS account with CLI configured
- Docker installed
- Terraform installed

## Terraform Configuration Overview (`main.tf`)

Key Highlights:
- Uses Ubuntu 22.04 LTS as the base AMI
- Configures EC2 instance with:
  - Encrypted EBS root volume
  - KMS key for volume encryption
  - IAM role for ECR image pull access
- Creates a security group allowing:
  - SSH access (port 22)
  - Flask application access (port 8081)
- Automated user data script for:
  - Docker installation
  - AWS CLI setup
  - ECR image pull
  - Container deployment

## Deployment Steps

### 1. Build and Push Docker Image

```bash
# Build Docker image
docker build -t flask-app .

# Login to AWS ECR
aws ecr get-login-password | docker login --username AWS --password-stdin <ECR_REPO_URL>

# Tag the image
docker tag flask-app:latest <ECR_IMAGE_URI>

# Push image to ECR
docker push <ECR_IMAGE_URI>
```

### 2. Deploy Infrastructure with Terraform

```bash
# Initialize Terraform
terraform init

# Preview the changes that will be made
terraform plan -var="region=YOUR_REGION" -var="ecr_repo_url=<YOUR_ECR_REPO_URL>" -var="ecr_image_uri=<YOUR_ECR_IMAGE_URI>"

# Apply the configuration
terraform apply -var="region=YOUR_REGION" -var="ecr_repo_url=<YOUR_ECR_REPO_URL>" -var="ecr_image_uri=<YOUR_ECR_IMAGE_URI>"
```

### 3. Access the API

```bash
# Retrieve the public IP and curl the API endpoint
curl http://$(terraform output -raw instance_public_ip):8081/api/v1
```

### 4. Clean Up

```bash
# Destroy the infrastructure
terraform destroy
```

## Notes
<img width="1223" alt="Screenshot 2025-03-28 at 5 47 33 PM" src="https://github.com/user-attachments/assets/e292425e-0d58-4439-8132-758f0c9ec9d4" />

- Replace `<ECR_REPO_URL>` with your actual Amazon ECR repository URL
- Replace `<ECR_IMAGE_URI>` with the full URI of your Docker image in ECR
- Modify the region and other variables as needed for your specific setup
- Always run `terraform plan` before `terraform apply` to review proposed changes

