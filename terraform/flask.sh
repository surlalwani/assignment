#!/bin/bash
# Initialize logging first
LOG_FILE="/var/log/flask-app-setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1
set -xe

echo "=== STARTING SETUP $(date) ==="

# 1. Install Docker
echo "==== INSTALLING DOCKER ===="
sudo apt-get update -y
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

# Install Docker
sudo apt-get update -y
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Configure Docker
sudo usermod -aG docker ubuntu
sudo systemctl enable docker
sudo systemctl start docker

# 2. Install AWS CLI
echo "==== INSTALLING AWS CLI ===="
sudo apt-get install -y unzip
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install
sudo rm -rf awscliv2.zip aws/

# 3. ECR Login & Run Container
aws ecr get-login-password --region ${region} | \
  sudo docker login --username AWS --password-stdin ${ecr_repo_url}  || \
  { echo "ECR login failed"; exit 1; }

sudo docker pull ${ecr_image_uri} || { echo "Image pull failed"; exit 1; }

sudo docker run -d \
  -p 8081:8081 \
  --restart unless-stopped \
  --name flask-app \
  ${ecr_image_uri} || { echo "Container start failed"; exit 1; }

echo "=== SETUP COMPLETED $(date) ==="
