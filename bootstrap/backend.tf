terraform {
  backend "s3" {
    encrypt = true
    # no variables allow here, therefore passed via commandline parameters to terraform
    #    key            = var.tfstate_s3bucketname
    #    region         = var.region
    #    bucket         = var.tfstate_s3bucketname
    #    dynamodb_table = var.tfstate_s3bucketname
    #    profile        = var.profile
  }
}
