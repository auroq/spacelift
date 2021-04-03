module "spacelift_webhook_defaults" {
  source = "git@github.com:auroq/spacelift.git"

  aws_region     = "us-west-2"
  aws_access_key = "awsaccesskey"
  aws_secret_key = "awssecretkey"

  tags = {
    key1 = "value1"
    key2 = "value2"
  }

  db_read_capacity = 20
  db_write_capacity = 20

  spacelift_account    = "myspaceliftaccount"
  spacelift_key_id     = "mykeyid"
  spacelift_key_secret = "mykeysecret"
  spacelift_stack_id   = "mystackid"
}
