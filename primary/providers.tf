terraform {
  backend "azurerm" {
    resource_group_name   = "rg-mono-primary"
    storage_account_name  = "mono058f3201"
    container_name        = "tfstate"
    key                   = "primary.tfstate"
    use_azuread_auth      = true
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}
