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

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "spacelift" {
  api_key_endpoint = "https://${var.spacelift_account}.app.spacelift.io"
  api_key_id       = var.spacelift_key_id
  api_key_secret   = var.spacelift_key_secret
}

resource "random_password" "spacelift_webhook_secret" {
  length  = 25
  special = true
  keepers = {
    secret_keeper = var.webhook_secret_keeper
  }
}
