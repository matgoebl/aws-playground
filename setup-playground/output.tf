### Write some outputs also to files to be used by playground (when not using remote state)

output "region" {
  value = var.region
}

resource "local_file" "playground_region" {
  content  = var.region
  filename = "${path.module}/../.playground.region"
}


### Save credentials for playground user with limited permissions

output "playground_access_key" {
  value = aws_iam_access_key.playground.id
}

output "playground_secret_key" {
  value     = aws_iam_access_key.playground.secret
  sensitive = true
}

resource "local_file" "playground_access_key" {
  content  = aws_iam_access_key.playground.id
  filename = "${path.module}/../.playground.key"
}

resource "local_file" "playground_secret_key" {
  content  = aws_iam_access_key.playground.secret
  filename = "${path.module}/../.playground.secret"
}
