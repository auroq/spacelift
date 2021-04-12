module "spacelift_webhook_mystack" {
  source = "git@github.com:auroq/spacelift.git"

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
