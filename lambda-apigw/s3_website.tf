variable "website_prefix" {
  type    = string
  default = "website"
}

locals {
  website_bucket_name = "${lower(var.website_prefix)}-${random_id.website_postfix.hex}"
}

resource "random_id" "website_postfix" {
  byte_length = 8
}


resource "aws_s3_bucket" "website_bucket" {
  bucket        = local.website_bucket_name
  force_destroy = true
}

output "bucket_name" {
  value = aws_s3_bucket.website_bucket.bucket
}
