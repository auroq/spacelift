resource "aws_dynamodb_table" "spacelift_webhook" {
  name           = var.db_name
  read_capacity  = var.db_read_capacity
  write_capacity = var.db_write_capacity
  hash_key       = "runId"
  range_key      = "state"

  attribute {
    name = "runId"
    type = "S"
  }

  attribute {
    name = "state"
    type = "S"
  }

  attribute {
    name = "stateVersion"
    type = "N"
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

  global_secondary_index {
    name            = "stateVersionIndex"
    hash_key        = "stateVersion"
    write_capacity  = var.db_write_capacity
    read_capacity   = var.db_read_capacity
    projection_type = "KEYS_ONLY"
  }

  tags = var.tags
}

