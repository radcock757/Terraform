terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

#Create the Security Group
resource "aws_security_group" "Jenkins_sg" {
  vpc_id = "vpc-05f530a52657d4677"

  ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #Allow access from my IP address via SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["70.160.118.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 Instance
resource "aws_instance" "Jenkins_EC2" {
  ami                    = "ami-007855ac798b5175e"
  instance_type          = "t2.micro"
  key_name               = "KeyPair1"
  vpc_security_group_ids = [aws_security_group.Jenkins_sg.id]
  user_data              = <<-EOF
#!/bin/bash
sudo wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key |sudo gpg --dearmor -o /usr/share/keyrings/jenkins.gpg
sudo sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins.gpg] http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update -y
sudo apt install openjdk-11-jdk -y
sudo apt install jenkins -y
sudo systemctl start jenkins.service
EOF

  tags = {
    Name      = "Jenkins"
    Terraform = "true"
  }
}

#Create S3 Bucket
resource "aws_s3_bucket" "ryana-jenkins-artifacts-s3" {
  bucket = "ryana-jenkins-artifacts-s3"

  tags = {
    Name      = "Jenkins"
    Terraform = "true"
  }
}

#Block Public access to S3 Bucket
resource "aws_s3_bucket_public_access_block" "block_public_access_s3" {
  bucket = aws_s3_bucket.ryana-jenkins-artifacts-s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "no-public-access" {
  bucket = aws_s3_bucket.ryana-jenkins-artifacts-s3.id
  acl    = "private"
}

#Print EC2 instance public IP address
output "instance_public_ip" {
  description = "Public IP address of Jenkins_EC2 instance"
  value       = [aws_instance.Jenkins_EC2.public_ip]
}
