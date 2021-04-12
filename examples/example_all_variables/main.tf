module "spacelift_webhook_mystack" {
  source = "git@github.com:auroq/spacelift.git"

  webhook_name          = "mystack-webhook"
  webhook_secret_keeper = "2020-03" # Using a date for this value can tell you when the secret was last rotated

  aws_role_name = "mystack-webhook"

  # tags can contain any keys and values, so you can use it to match your organization's AWS resource tagging practices.
  tags = {
    key1 = "value1"
    key2 = "value2"
  }

  db_read_capacity  = 20
  db_write_capacity = 20

  spacelift_stack_id   = "mystackid"
}

provider "aws" {
  region     = "us-west-2"
  access_key = "awsaccesskey"
  secret_key = "awssecretkey"
}

provider "spacelift" {
  api_key_endpoint = "myspaceliftaccount.app.spacelift.io"
  api_key_id       = "mykeyid"
  api_key_secret   = "mykeysecret"
}
