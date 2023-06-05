resource "random_pet" "bucket_name" {
  prefix = "bucket-wordcount"
  length = 4
}

resource "aws_s3_bucket" "wordcount-bucket" {
  bucket = random_pet.bucket_name.id

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

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.wordcount-bucket.id
  policy = data.aws_iam_policy_document.allow_public_access.json
}

data "aws_iam_policy_document" "allow_public_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.wordcount-bucket.arn,
      "${aws_s3_bucket.wordcount-bucket.arn}/*",
    ]
  }
}