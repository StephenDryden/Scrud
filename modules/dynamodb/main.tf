resource "aws_dynamodb_table" "http-crud-tutorial-items" {
  name             = "${var.project_name}items"
  hash_key         = "id"
  billing_mode     = "PAY_PER_REQUEST"


  attribute {
    name = "id"
    type = "S"
  }
}