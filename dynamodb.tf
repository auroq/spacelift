resource "aws_dynamodb_table" "spacelift_webhook" {
  name           = var.db_name
  read_capacity  = var.db_read_capacity
  write_capacity = var.db_write_capacity
  hash_key       = "stateVersion"
  range_key      = "state"

  attribute {
    name = "stateVersion"
    type = "N"
  }

  attribute {
    name = "state"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  global_secondary_index {
    name            = "timestampIndex"
    hash_key        = "timestamp"
    write_capacity  = var.db_write_capacity
    read_capacity   = var.db_read_capacity
    projection_type = "KEYS_ONLY"
  }

  tags = var.tags
}

