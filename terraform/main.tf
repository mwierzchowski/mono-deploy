provider "azurerm" {
  features {}
}

variable "location" {
  default = "West Central US"
}

variable "resource_group_name" {
  default = "rg-mono"
}

resource "azurerm_resource_group" "mono" {
  name     = var.resource_group_name
  location = var.location
}
