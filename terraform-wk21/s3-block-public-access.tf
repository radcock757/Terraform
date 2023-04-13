#Block Public access to S3 Bucket
resource "aws_s3_bucket_public_access_block" "block_public_access_s3" {
  bucket = aws_s3_bucket.web-store-s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}