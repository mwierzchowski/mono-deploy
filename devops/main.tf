locals {
  family      = "mono"
  group       = "devops"
  location    = "northeurope"
  tags = {
    repo    = "mono-deploy"
    service = local.group
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

data "azurerm_resource_group" "devops" {
  name = "rg-mono-devops"
}

data "azurerm_storage_account" "devops" {
  name                = "stmonodevopse1125f87"
  resource_group_name = data.azurerm_resource_group.devops.name
}