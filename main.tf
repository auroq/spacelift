terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    spacelift = {
      source = "spacelift.io/spacelift-io/spacelift"
    }
  }
  required_version = ">= 0.14"
}

resource "random_password" "spacelift_webhook_secret" {
  length  = 25
  special = true
  keepers = {
    secret_keeper = var.webhook_secret_keeper
  }
}
