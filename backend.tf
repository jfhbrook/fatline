terraform {
  required_version = ">= 1.11"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.3"
    }
  }
}
