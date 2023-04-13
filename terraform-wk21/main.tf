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
resource "aws_security_group" "Web-Store-SG" {
  vpc_id = var.default-vpc

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "instances_user_data" {
  template = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y apache2
    echo "Welcome to my Web-Store-ASG!" > var/www/html/index.html
    systemctl enable apache2
    systemctl start apache2
  EOF
}

resource "aws_launch_template" "Web-Store-Template" {
  image_id      = var.ami_id
  instance_type = var.instance-type
  key_name      = "KeyPair1"
  name_prefix   = "Web-Store"
  network_interfaces {
    associate_public_ip_address = "true"
    security_groups             = [aws_security_group.Web-Store-SG.id]
  }

  user_data = base64encode(data.template_file.instances_user_data.rendered)

  tags = {
    Name      = "Web-Store"
    Terraform = "true"
  }
}

resource "aws_autoscaling_group" "Web-Store-ASG" {
  max_size            = 5
  min_size            = 2
  desired_capacity    = 2
  health_check_type   = "ELB"
  vpc_zone_identifier = [var.subnet-1, var.subnet-2]
  launch_template {
    id      = aws_launch_template.Web-Store-Template.id
    version = "$Latest"
  }
}

#Create S3 Bucket
resource "aws_s3_bucket" "web-store-s3" {
  bucket = "web-store-s3"

  tags = {
    Name      = "Web-Store"
    Terraform = "true"
  }
}

resource "aws_s3_bucket_policy" "s3-backend-policy" {
  bucket = aws_s3_bucket.web-store-s3.id
  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": [ "s3:*" ],
        "Resource": [
          "${aws_s3_bucket.web-store-s3.arn}",
          "${aws_s3_bucket.web-store-s3.arn}/*"
        ]
      }
    ]
  }
EOF
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.web-store-s3.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "s3-db-backend" {
  name           = "s3-db-backend"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name      = "Web-Store"
    Terraform = "true"
  }
}