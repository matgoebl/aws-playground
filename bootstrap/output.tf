### Write some outputs also to files to be used by playground (when not using remote state)

output "region" {
  value = var.region
}

resource "local_file" "playground_region" {
  content  = var.region
  filename = "${path.module}/../.playground.region"
}

output "playground_state_s3bucket" {
  value = aws_s3_bucket.state_s3bucket.id
}

resource "local_file" "playground_state_s3bucket" {
  content  = aws_s3_bucket.state_s3bucket.id
  filename = "${path.module}/../.playground.state_s3bucket"
}


### Save credentials for playground user with limited permissions

output "playground_region" {
  value = var.region
}

output "playground_user" {
  value = aws_iam_user.playground.arn
}

output "playground_github_role" {
  value = aws_iam_role.github_role.arn
}

output "playground_access_key" {
  value = aws_iam_access_key.playground.id
}

output "playground_secret_key" {
  value     = aws_iam_access_key.playground.secret
  sensitive = true
}

resource "local_file" "playground_user" {
  content  = aws_iam_user.playground.arn
  filename = "${path.module}/../.playground.user"
}

resource "local_file" "playground_access_key" {
  content  = aws_iam_access_key.playground.id
  filename = "${path.module}/../.playground.key"
}

resource "local_file" "playground_secret_key" {
  content  = aws_iam_access_key.playground.secret
  filename = "${path.module}/../.playground.secret"
}
