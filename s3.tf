resource "aws_s3_bucket" "private_bucket" {
  bucket = "robt-bucket"
}

resource "aws_s3_bucket_versioning" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id
  policy = data.aws_iam_policy_document.private_bucket.json
}
