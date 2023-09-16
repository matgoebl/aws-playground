

# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["lambda.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

# resource "aws_iam_role" "lambda_role" {
#   name               = "lambda_role"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

# data "aws_iam_policy_document" "lambda_policy" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "logs:CreateLogStream",
#       "logs:PutLogEvents"
#     ]

#     resources = [
#       "arn:aws:logs:*:*:*"
#     ]
#   }

#   statement {
#     effect = "Allow"

#     actions = [
#       "s3:*"
#     ]

#     resources = [
#       "${aws_s3_bucket.website_bucket.arn}",
#       "${aws_s3_bucket.website_bucket.arn}/*",
#     ]
#   }
# }

# resource "aws_iam_policy" "lambda_policy" {
#   name        = "lambda_policy"
#   description = "lambda_policy"
#   policy      = data.aws_iam_policy_document.lambda_policy.json
# }

# resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
#   name       = "lambda_policy_attachment"
#   roles      = [aws_iam_role.lambda_role.name]
#   policy_arn = aws_iam_policy.lambda_policy.arn
# }

data "aws_iam_role" "lambda_role" {
  name = "playground_lambda_role"
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = 3
  lifecycle {
    prevent_destroy = false
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/tmp_lambda_function_payload.zip"
}

resource "aws_lambda_function" "test_lambda" {
  function_name    = var.lambda_name
  handler          = "lambda_function.lambda_handler"
  role             = data.aws_iam_role.lambda_role.arn
  filename         = "${path.module}/tmp_lambda_function_payload.zip"
  source_code_hash = data.archive_file.lambda.output_base64sha256


  runtime = "python3.9"
  timeout = 10

  environment {
    variables = {
      s3_bucket = var.website_bucket
      # split(":", website_bucket.arn)[5]
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda_log_group]
}


resource "aws_lambda_permission" "allow_callers" {
  for_each = toset(var.lambda_allowed_callers)
  # statement_id  = "AllowExecutionFromOtherAccount"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  # function_url_auth_type = "AWS_IAM"
  principal = each.value
  # source_account = split(":", each.value)[4]
}
