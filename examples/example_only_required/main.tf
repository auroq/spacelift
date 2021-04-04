module "spacelift_webhook_mystack" {
  source = "git@github.com:auroq/spacelift.git"

  aws_region     = "us-west-2"
  aws_access_key = "awsaccesskey"
  aws_secret_key = "awssecretkey"

  spacelift_account    = "myspaceliftaccount"
  spacelift_key_id     = "mykeyid"
  spacelift_key_secret = "mykeysecret"
  spacelift_stack_id   = "mystackid"
}
