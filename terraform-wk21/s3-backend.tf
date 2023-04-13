terraform {
  backend "s3" {
    bucket         = "web-store-s3"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "s3-db-backend"
  }
}