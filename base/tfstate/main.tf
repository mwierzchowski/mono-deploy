locals {
  stack = "tfstate"
  group = "rg-${var.family}-${local.stack}"
  tags = {
    repo  = var.repo
    stack = local.stack
  }
}

resource "azurerm_resource_group" "tfstate" {
  name     = local.group
  location = var.location
  tags     = local.tags
}

resource "azurerm_storage_account" "tfstate" {
  name                            = var.tfstate.storage
  resource_group_name             = azurerm_resource_group.tfstate.name
  location                        = azurerm_resource_group.tfstate.location
  account_tier                    = var.storage_defaults.tier
  account_replication_type        = var.storage_defaults.replication
  min_tls_version                 = var.storage_defaults.tls_version
  https_traffic_only_enabled      = var.storage_defaults.https_only
  allow_nested_items_to_be_public = var.storage_defaults.nested_public
  tags                            = local.tags
}

resource "azurerm_storage_container" "container" {
  name                  = local.stack
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = var.storage_defaults.access
}

resource "azurerm_management_lock" "tfstate_lock" {
  name       = "${local.stack}-st-lock"
  scope      = azurerm_storage_account.tfstate.id
  lock_level = "CanNotDelete"
  notes      = "Prevent accidental deletion of this resource group."
}

output "tf_backend" {
  value = {
    resource_group_name  = azurerm_resource_group.tfstate.name
    storage_account_name = azurerm_storage_account.tfstate.name
    container_name       = azurerm_storage_container.container.name
  }
}
