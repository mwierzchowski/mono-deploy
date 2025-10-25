resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  stack   = "preview"
  group   = "rg-${var.family}-${local.stack}"
  storage = "st${var.family}${local.stack}${random_id.suffix.hex}"
  tags = {
    repo  = var.repo
    stack = local.stack
  }
  devops_group = "rg-${var.family}-devops"
}

resource "azurerm_resource_group" "preview" {
  name     = local.group
  location = var.location
  tags     = local.tags
}

resource "azurerm_storage_account" "preview" {
  name                            = local.storage
  resource_group_name             = azurerm_resource_group.preview.name
  location                        = azurerm_resource_group.preview.location
  account_tier                    = var.storage_defaults.tier
  account_replication_type        = var.storage_defaults.replication
  min_tls_version                 = var.storage_defaults.tls_version
  https_traffic_only_enabled      = var.storage_defaults.https_only
  allow_nested_items_to_be_public = var.storage_defaults.nested_public
  tags                            = local.tags
}

output "storage" {
  value = azurerm_storage_account.preview.name
}