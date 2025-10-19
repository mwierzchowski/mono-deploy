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

resource "azurerm_resource_group" "devops" {
  name     = "rg-${local.family}-${local.group}"
  location = local.location
  tags     = local.tags
}

resource "azurerm_storage_account" "devops" {
 name                            = "st${local.family}${local.group}${random_id.suffix.hex}"
 resource_group_name             = azurerm_resource_group.devops.name
 location                        = azurerm_resource_group.devops.location
 account_tier                    = "Standard"
 account_replication_type        = "LRS"
 min_tls_version                 = "TLS1_2"
 https_traffic_only_enabled      = true
 allow_nested_items_to_be_public = false
 tags                            = local.tags
}
