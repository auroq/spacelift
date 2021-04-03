module "spacelift_webhook_defaults" {
  source = "git@github.com:auroq/spacelift.git"

  webhook_name          = "mystack-webhook"
  webhook_secret_keeper = "2020-03" # Using a date for this value can tell you when the secret was last rotated

  aws_region     = "us-west-2"
  aws_access_key = "awsaccesskey"
  aws_secret_key = "awssecretkey"

  aws_role_name = "mystack-webhook"

  # tags can contain any keys and values, so you can use it to match your organization's AWS resource tagging practices.
  tags = {
    key1 = "value1"
    key2 = "value2"
  }

  db_read_capacity  = 20
  db_write_capacity = 20

  spacelift_account    = "myspaceliftaccount"
  spacelift_key_id     = "mykeyid"
  spacelift_key_secret = "mykeysecret"
  spacelift_stack_id   = "mystackid"
}
