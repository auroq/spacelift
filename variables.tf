variable "webhook_name" {
  default     = "spacelift-webhook"
  description = "The name of the webhook context. This will be used for naming various resources such as the API, the lambda, and the database"
}

variable "webhook_secret_keeper" {
  default     = ""
  description = "This value is used for rotating the Spacelift webhook secret which is used for request validation. Any time this value changes, the secret will be rotated."
}

### AWS
variable "aws_role_name" {
  type        = string
  default     = "spacelift-webhook"
  description = "The name of the role to create for the AWS infrastructure to use."
}

variable "tags" {
  default     = {}
  description = "Any tags to use for tagging AWS infrastructure. This should be an object."
}

### DynamoDB
variable "db_read_capacity" {
  default     = 20
  description = "The read capacity of the DynamoDB database instance"
}
variable "db_write_capacity" {
  default     = 20
  description = "The write capacity of the DynamoDB database instance"
}

### Spacelift
variable "spacelift_stack_id" {
  type        = string
  description = "The ID of the Spacelift stack on which to create the webhook integration"
}
