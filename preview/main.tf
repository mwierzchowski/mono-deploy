locals {
  family      = "mono"
  group       = "preview"
  location    = "northeurope"
  tags = {
    repo    = "mono-deploy"
    service = local.group
  }
}

resource "azurerm_resource_group" "preview" {
  name     = "rg-${local.family}-${local.group}"
  location = local.location
  tags     = local.tags
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "azurerm_storage_account" "preview" {
 name                            = "st${local.family}${local.group}${random_id.suffix.hex}"
 resource_group_name             = azurerm_resource_group.preview.name
 location                        = azurerm_resource_group.preview.location
 account_tier                    = "Standard"
 account_replication_type        = "LRS"
 min_tls_version                 = "TLS1_2"
 https_traffic_only_enabled      = true
 allow_nested_items_to_be_public = false
 tags                            = local.tags
}

data "azurerm_resource_group" "devops" {
  name = "rg-mono-devops"
}

data "azurerm_storage_account" "devops" {
  name                = "stmonodevopsb1e7a48d"
  resource_group_name = data.azurerm_resource_group.devops.name
}

data "azurerm_container_registry" "devops" {
  name                = "acrmonodevopsb1e7a48d"
  resource_group_name = data.azurerm_resource_group.devops.name
}