# Flask API Deployment on AWS EC2 Quick Start Guide

## Prerequisites

- AWS account with CLI configured
- Docker installed
- Terraform installed

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

# Apply Terraform configuration
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

- Replace `<ECR_REPO_URL>` with your actual Amazon ECR repository URL
- Replace `<ECR_IMAGE_URI>` with the full URI of your Docker image in ECR
- Modify the region and other variables as needed for your specific setup