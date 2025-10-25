terraform {
  backend "azurerm" {
    resource_group_name  = "rg-mono-tfstate"
    storage_account_name = "stmonotfstatee1125f87"
    container_name       = "tfstate"
    key                  = "devops.tfstate"
    use_azuread_auth     = true
  }

  required_version = ">= 1.8.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm",
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}
