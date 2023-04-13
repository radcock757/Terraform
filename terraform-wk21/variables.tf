variable "subnet-1" {
  description = "Subnet 1"
  default     = "subnet-0c23be44ab1c5564c"
}

variable "subnet-2" {
  description = "Subnet 2"
  default     = "subnet-0c1fed6313c663cb2"
}

variable "default-vpc" {
  description = "Default VPC"
  default     = "vpc-05f530a52657d4677"
}

variable "ami_id" {
  description = "AMI ID"
  default     = "ami-007855ac798b5175e"
}

variable "instance-type" {
  description = "EC2 Instance Type"
  default     = "t2.micro"
}