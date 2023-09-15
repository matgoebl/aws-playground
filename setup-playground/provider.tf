terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.10"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
  required_version = "~>1.4"
}

provider "aws" {
  profile = var.profile
  region  = var.region
  default_tags {
    tags = {
      "env" : "playground"
    }
  }
}
