Flask API Deployment on AWS EC2
Quick Start Guide
Prerequisites
AWS account with CLI configured

Docker installed

Terraform installed

Deployment Steps
Build and push Docker image:

bash
Copy
docker build -t flask-app .
aws ecr get-login-password | docker login --username AWS --password-stdin <ECR_REPO_URL>
docker tag flask-app:latest <ECR_IMAGE_URI>
docker push <ECR_IMAGE_URI>
Deploy infrastructure:

bash
Copy
terraform init
terraform apply \
  -var="region=us-west-2"
  -var="ecr_repo_url=<YOUR_ECR_REPO_URL>" \
  -var="ecr_image_uri=<YOUR_ECR_IMAGE_URI>"
Access the API:

bash
Copy
curl http://$(terraform output -raw instance_public_ip):8081/api/v1
Clean Up
bash
Copy
terraform destroy