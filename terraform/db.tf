resource "aws_dynamodb_table" "dynamo-db" {
  name = "users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "userObjIndex"


  attribute {
    name = "userObjIndex"
    type = "S"
  }

}

