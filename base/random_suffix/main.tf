terraform {
  required_version = ">= 1.8"
  backend "local" {}
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

output "suffix" {
  value = "${random_id.suffix.hex}"
}
