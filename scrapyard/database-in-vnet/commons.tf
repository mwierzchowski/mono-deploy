variable "location" {
  default = "North Europe"
}

variable "app_name" {
  default = "mono"
}

variable "env_name" {
  default = "staging"
}

variable "net_allowed_ip" {
  sensitive = true
}

variable "net_address_space" {
  default = "10.0.0.0/16"
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

locals {
  default_resource_name = "${var.app_name}_${var.env_name}"
  default_resource_simplename = "${var.app_name}${var.env_name}"
  default_resource_uniquename = "${local.default_resource_simplename}${random_string.suffix.result}"
}

resource "azurerm_resource_group" "default" {
  name     = "${local.default_resource_name}_resources"
  location = var.location
}

resource "azurerm_virtual_network" "default" {
  name                             = "${local.default_resource_name}_vnet"
  location                         = var.location
  resource_group_name = azurerm_resource_group.default.name
  address_space             = [var.net_address_space]
}

output "resource_group_name" {
  value = azurerm_resource_group.default.name
}

output "virtual_network_name" {
  value = azurerm_virtual_network.default.name
}
