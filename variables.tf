variable "aws_region" { type = string }
variable "aws_access_key" { type = string }
variable "aws_secret_key" { type = string }

variable "aws_role_name" { type = string }

variable "tags" {}

### API Gateway

variable "api_name" {
  default = "spacelift-webhook"
}

### DynamoDB

variable "db_name" {
  default = "spacelift-webhook"
}

variable "db_read_capacity" {
  default = 20
}

variable "db_write_capacity" {
  default = 20
}
