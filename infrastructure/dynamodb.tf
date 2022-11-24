resource "aws_dynamodb_table" "Patent-dynamodb-table" {
  name             = "Patent_information"
  hash_key         = "name"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  read_capacity    = 25
  write_capacity   = 25

  attribute {
    name = "name"
    type = "S"
  }
}
