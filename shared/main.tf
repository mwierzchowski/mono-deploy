terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
 backend "azurerm" {
   resource_group_name  = "mono_shared"
   storage_account_name = "monoshared5gxr2n"
   container_name             = "tfstate"
   key                                  = "shared/terraform.tfstate"
 }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "default" {
  name     = "${var.app_name}_${var.cfg_name}"
  location = var.location
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_storage_account" "default" {
  name                                  = "${var.app_name}${var.cfg_name}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.default.name
  location                              = azurerm_resource_group.default.location
  account_tier                      = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfstate" {
 name                               = "tfstate"
 storage_account_id       = azurerm_storage_account.default.id
 container_access_type = "private"
}
