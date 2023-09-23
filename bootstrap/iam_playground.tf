### Create playground user with limited permissions

resource "aws_iam_user" "playground" {
  name          = "playground"
  force_destroy = true
}

resource "aws_iam_access_key" "playground" {
  user = aws_iam_user.playground.name
}


### Attach default AWS ReadOnly policy

data "aws_iam_policy" "ReadOnlyAccess" {
  arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_user_policy_attachment" "playground-readonly" {
  user       = aws_iam_user.playground.name
  policy_arn = data.aws_iam_policy.ReadOnlyAccess.arn
}


### Add some local permissions

data "aws_iam_policy_document" "playground_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      # "logs:CreateLogStream",
      # "logs:PutLogEvents",
      "logs:*",
      "lambda:*",
      "dynamodb:*",
      "iam:GetRole",
      "iam:PassRole"
    ]

    resources = [
      "*"
      # "arn:aws:logs:*:*:*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      "arn:aws:iam::772603373501:role/playground_lambda_role"
    ]
  }

}

resource "aws_iam_user_policy" "playground" {
  name   = "playground"
  user   = aws_iam_user.playground.name
  policy = data.aws_iam_policy_document.playground_policy.json
}

resource "aws_iam_policy" "playground_policy" {
  name        = "playground_policy"
  description = "playground_policy"
  policy      = data.aws_iam_policy_document.playground_policy.json
}

resource "aws_iam_user_policy_attachment" "playground_policy_attach" {
  user       = aws_iam_user.playground.name
  policy_arn = aws_iam_policy.playground_policy.arn
}


### Add a role for Lambdas (as creating IAM ressources is not permitted to the playground user)

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "playground_lambda_role" {
  name               = "playground_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# resource "aws_iam_policy_attachment" "playground_policy_attachment" {
#   name       = "playground_policy_attachment"
#   roles      = [aws_iam_role.playground_lambda_role.name]
#   policy_arn = aws_iam_policy.playground_policy.arn
# }

resource "aws_iam_role_policy_attachment" "lambda_playground_policy_attachment" {
  role       = aws_iam_role.playground_lambda_role.name
  policy_arn = aws_iam_policy.playground_policy.arn
}
