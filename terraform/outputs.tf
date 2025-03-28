output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.flask_instance.public_ip
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for encryption"
  value       = aws_kms_key.ebs_encryption.arn
}