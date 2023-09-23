# S3 Bucket for State

resource "aws_s3_bucket" "state_s3bucket" {
  bucket = var.state_s3bucket

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_ownership_controls" "state_s3bucket_ownership" {
  bucket = aws_s3_bucket.state_s3bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "state_s3bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.state_s3bucket_ownership]

  bucket = aws_s3_bucket.state_s3bucket.id
  acl    = "private"
}
