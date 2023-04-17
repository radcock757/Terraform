variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_name" {
  type    = string
  default = "custom_vpc"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  default = {
    "private_subnet_1" = 1
    "private_subnet_2" = 2
  }
}

variable "public_subnets" {
  default = {
    "public_subnet_1" = 1
    "public_subnet_2" = 2
  }
}

variable "ami_id" {
  description = "AMI ID"
  default     = "ami-007855ac798b5175e"
}

variable "instance-type" {
  description = "EC2 Instance Type"
  default     = "t2.micro"
}