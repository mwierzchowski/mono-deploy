terraform {
  backend "azurerm" {
    resource_group_name  = "rg-mono-primary"
    storage_account_name = "mono058f3201"
    container_name       = "tfstate"
    key                  = "primary.tfstate"
    use_azuread_auth     = true
  }

  required_version = ">= 1.6.0"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}
