variable "region" {
  type = string
}

variable "lambda_name" {
  type    = string
  default = "lambda_function"
}

variable "lambda_allowed_callers" {
  type    = list(string)
  default = []
}

