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

# data "terraform_remote_state" "playground_setup" {
#   backend = "local"
#   config = {
#     path = "./setup-playground/terraform.tfstate"
#   }
# }

provider "aws" {
  #   region     = data.terraform_remote_state.playground_setup.outputs.region
  #   access_key = data.terraform_remote_state.playground_setup.outputs.playground_access_key
  #   secret_key = data.terraform_remote_state.playground_setup.outputs.playground_secret_key
}
