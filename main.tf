module "s3_website" {
  source = "./s3-website/"
}

output "website_url" {
  value = module.s3_website.website_url
}


module "lambda_apigw" {
  source         = "./lambda-apigw/"
  lambda_name    = var.lambda_name
  website_bucket = module.s3_website.website_bucket
}

variable "lambda_name" {
  type    = string
  default = "lambda_function"
}
