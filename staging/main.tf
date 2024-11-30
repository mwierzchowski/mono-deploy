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
   key                                  = "staging/terraform.tfstate"
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
