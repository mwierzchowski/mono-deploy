terraform {
  backend "azurerm" {
    resource_group_name = "rg-mono-tfstate"
    storage_account_name = "stmonotfzilu5t"
    container_name       = "tfstate"
    key                  = "shared.tfstate"
    use_azuread_auth     = true
  }

  required_version = ">= 1.8.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm",
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}
