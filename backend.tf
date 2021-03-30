terraform {
  backend "remote" {
    organization = "auroq"

    workspaces {
      name = "spacelift"
    }
  }
}
