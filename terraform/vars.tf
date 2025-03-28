variable "region" {
    description="AWS Region"
    type = string
    default = "us-west-2"
}

variable "instance_type"{
    description = "AWS Instance type"
    type = string
    default = "t2.micro"
}

variable "ebs_size" {
    description = "EBS Volume size"
    type = number
    default = 10
}

variable "ecr_repo_url" {
  description = "Base ECR repository URL (e.g., 123456789012.dkr.ecr.us-east-1.amazonaws.com)"
  type        = string
  default = "placeholder-ecr-repo-url"
}

variable "ecr_image_uri" {
  description = "Full ECR image URI (e.g., 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-flask-app:latest)"
  type        = string
  default = "placeholder-ecr-image-uri"
}