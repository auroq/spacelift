variable "webhook_name" {
  default = "spacelift-webhook"
  description = "The name of the webhook context. This will be used for naming various resources such as the API, the lambda, and the database"
}

### AWS
variable "aws_region" {
  type = string
  description = "The AWS region in which to deploy the webhook"
}
variable "aws_access_key" {
  type = string
  sensitive = true
  description = "AWS Access Key to use for authenticating to AWS to create resources"
}
variable "aws_secret_key" {
  type = string
  sensitive = true
  description = "AWS Access Key to use for authenticating to AWS to create resources"
}

variable "aws_role_name" {
  type = string
  default = "spacelift-webhook"
  description = "The name of the role to create for the webhook will use."
}

variable "tags" {
  description = "Any tags to use for tagging AWS infrastructure. This should be an object."
}

### DynamoDB
variable "db_read_capacity" {
  default = 20
  description = "The read capacity of the DynamoDB database instance"
}
variable "db_write_capacity" {
  default = 20
  description = "The write capacity of the DynamoDB database instance"
}

### Spacelift
variable "spacelift_account" {
  type = string
  description = "The spacelift account with which to integrate"
}
variable "spacelift_key_id" {
  type = string
  description = "The Spacelift API key ID to use for creating the webhook integration in spacelift"
}
variable "spacelift_key_secret" {
  type = string
  description = "The Spacelift API key secret to use for creating the webhook integration in spacelift"
}
variable "spacelift_stack_id" {
  type = string
  description = "The ID of the Spacelift stack on which to create the webhook integration"
}
