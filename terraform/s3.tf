# S3 Bucket for MWAA
resource "aws_s3_bucket" "mwaa" {
  bucket = "${var.environment_name}-mwaa-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${var.environment_name}-mwaa-bucket"
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "mwaa" {
  bucket = aws_s3_bucket.mwaa.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "mwaa" {
  bucket = aws_s3_bucket.mwaa.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "mwaa" {
  bucket = aws_s3_bucket.mwaa.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}
