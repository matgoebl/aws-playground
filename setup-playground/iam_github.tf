# https://github.com/aws-actions/configure-aws-credentials
# https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services
# https://dev.to/mmiranda/github-actions-authenticating-on-aws-using-oidc-3d2n

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    # https://github.blog/changelog/2023-06-27-github-actions-update-on-oidc-integration-with-aws/
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"

  ]
}


data "aws_iam_policy_document" "github_oicd_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    # Token contents: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:matgoebl/aws-playground:*"
      ]
    }
  }
}

resource "aws_iam_role" "github_role" {
  name               = "plaground-github-role"
  assume_role_policy = data.aws_iam_policy_document.github_oicd_assume_role.json
}




data "aws_iam_policy_document" "github_permissions" {
  statement {
    actions = [
      "s3:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "github_permissions" {
  name   = "github-permissions"
  policy = data.aws_iam_policy_document.github_permissions.json
}

resource "aws_iam_role_policy_attachment" "github" {
  role       = aws_iam_role.github_role.name
  policy_arn = aws_iam_policy.github_permissions.arn
}
