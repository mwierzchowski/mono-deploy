locals {
  stack = "devops"
  group = "rg-${var.family}-${local.stack}"
  tags = {
    repo  = var.repo
    stack = local.stack
  }
  ci_name = "${var.family}-publisher"
}

resource "azurerm_resource_group" "rg" {
  name     = local.group
  location = var.location
  tags     = local.tags
}

resource "azurerm_storage_account" "st" {
  name                            = var.devops.storage
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  account_tier                    = var.devops.tier
  account_replication_type        = var.devops.replication
  min_tls_version                 = var.devops.tls_version
  https_traffic_only_enabled      = var.devops.https_only
  allow_nested_items_to_be_public = var.devops.nested_public
  tags                            = local.tags
}

data "azuread_service_principal" "app_ci" {
  display_name = local.ci_name
}



# TODO devops lock?