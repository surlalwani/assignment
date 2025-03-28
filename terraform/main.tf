terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}


provider "aws" {
  region = var.region
}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnets" "default" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}

# data "aws_ami" "amazon_linux" {
#     most_recent = true
#     owners = ["amazon"]

#     filter {
#        name   = "name"
#        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#     }
# }

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's owner ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_kms_key" "ebs_encryption" {
  description             = "An example symmetric encryption KMS key"
  enable_key_rotation     = true
  deletion_window_in_days = 20

}


resource "aws_instance" "flask_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  associate_public_ip_address  = true
  vpc_security_group_ids = [aws_security_group.flask_security_group.id]
  iam_instance_profile = aws_iam_instance_profile.ecr_access.name

  root_block_device {
    encrypted   = true
    kms_key_id  = aws_kms_key.ebs_encryption.arn
    volume_size = 8
    volume_type = "gp3"
  }

   user_data = templatefile("flask.sh", {
    region        = var.region
    ecr_repo_url  = var.ecr_repo_url
    ecr_image_uri = var.ecr_image_uri
   })



  tags = {
    Name = "Flask app machine"
  }

}

# IAM Role for ECR Access
resource "aws_iam_role" "ecr_access_role" {
  name = "flask-app-ecr-access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.ecr_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ecr_access" {
  name = "flask-app-ecr-profile"
  role = aws_iam_role.ecr_access_role.name
}

resource "aws_ebs_volume" "example" {
  availability_zone = aws_instance.flask_instance.availability_zone
  size              =  var.ebs_size
  encrypted         = true
  kms_key_id        = aws_kms_key.ebs_encryption.arn
  tags = {
    Name = "EBS-encrypted-${var.region}"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.example.id
  instance_id = aws_instance.flask_instance.id
}


resource "aws_security_group" "flask_security_group" {
  name        = "allow_ssh_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "flask_security_group"
  }
}


# Allow SSH access from anywhere (consider restricting this in production)
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.flask_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Allow Flask app access (8081) from anywhere
resource "aws_vpc_security_group_ingress_rule" "allow_flask_ipv4" {
  security_group_id = aws_security_group.flask_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8081
  ip_protocol       = "tcp"
  to_port           = 8081
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.flask_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # All traffic
}

