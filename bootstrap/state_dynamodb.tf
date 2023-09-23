# DynamoDB for State Locking

resource "aws_dynamodb_table" "state_dynamodb" {
  name         = var.state_dynamodb
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }
}
