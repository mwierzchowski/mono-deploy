locals {
  stack = "tfstate"
  group = "rg-${var.family}-${local.stack}"
  tags = {
    repo  = var.repo
    stack = local.stack
  }
}

resource "azurerm_resource_group" "rg" {
  name     = local.group
  location = var.location
  tags     = local.tags
}

resource "azurerm_storage_account" "st" {
  name                            = var.tfstate.storage
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  account_tier                    = var.tfstate.tier
  account_replication_type        = var.tfstate.replication
  min_tls_version                 = var.tfstate.tls_version
  https_traffic_only_enabled      = var.tfstate.https_only
  allow_nested_items_to_be_public = var.tfstate.nested_public
  tags                            = local.tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = local.stack
  storage_account_id    = azurerm_storage_account.st.id
  container_access_type = var.tfstate.access
}

output "tf_backend" {
  value = {
    resource_group_name  = azurerm_resource_group.rg.name
    storage_account_name = azurerm_storage_account.st.name
    container_name       = azurerm_storage_container.tfstate.name
  }
}
