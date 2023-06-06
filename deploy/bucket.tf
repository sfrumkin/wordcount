resource "random_pet" "bucket_name" {
  prefix = "bucket-wordcount"
  length = 4
}

resource "aws_s3_bucket" "wordcount-bucket" {
  bucket        = random_pet.bucket_name.id
  force_destroy = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-WordCountBucket"
    },
  )
}

resource "aws_s3_bucket_server_side_encryption_configuration" "wordcount-encryption" {
  bucket = aws_s3_bucket.wordcount-bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "wordcount_public_block" {
  bucket = aws_s3_bucket.wordcount-bucket.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
