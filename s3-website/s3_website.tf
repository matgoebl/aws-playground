variable "website_prefix" {
  type    = string
  default = "website"
}



locals {
  website_bucket_name = "${lower(var.website_prefix)}-${random_id.website_postfix.hex}"
  website_dir         = "${path.module}/website/"
}

resource "random_id" "website_postfix" {
  byte_length = 8
}




resource "aws_s3_bucket" "website_bucket" {
  bucket        = local.website_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "website_bucket_owner" {
  bucket = aws_s3_bucket.website_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "website_bucket_access" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "website_bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.website_bucket_owner,
    aws_s3_bucket_public_access_block.website_bucket_access,
  ]

  bucket = aws_s3_bucket.website_bucket.id
  acl    = "public-read"
}

# data "aws_iam_policy_document" "website_bucket_policy" {
#   statement {
#     actions = [
#       "s3:GetObject",
#       "s3:ListBucket"
#     ]
#     principals {

#       type        = "AWS"
#       identifiers = ["*"]
#     }
#     resources = [
#       "${aws_s3_bucket.website_bucket.arn}",
#       "${aws_s3_bucket.website_bucket.arn}/*",
#     ]
#   }
# }

# resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
#   bucket = aws_s3_bucket.website_bucket.id
#   policy = data.aws_iam_policy_document.website_bucket_policy.json
# }

resource "aws_s3_bucket_website_configuration" "website_bucket_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

}

variable "mime_types" {
  default = {
    txt  = "text/plain"
    htm  = "text/html"
    html = "text/html"
    css  = "text/css"
    js   = "application/javascript"
    map  = "application/javascript"
    json = "application/json"
    png  = "image/png"
    jpg  = "image/jpg"
    jpeg = "image/jpg"
    gif  = "image/gif"
    svg  = "image/svg+xml"
  }
}

resource "aws_s3_object" "website_content" {
  for_each = fileset(local.website_dir, "**")
  bucket   = aws_s3_bucket.website_bucket.bucket
  key      = replace(each.value, local.website_dir, "")
  source   = "${local.website_dir}/${each.value}"
  etag     = filemd5("${local.website_dir}/${each.value}")

  content_type = lookup(var.mime_types, split(".", each.value)[length(split(".", each.value)) - 1], "text/html")

  acl = "public-read"

  depends_on = [aws_s3_bucket_public_access_block.website_bucket_access]
}
