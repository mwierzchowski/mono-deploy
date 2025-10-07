resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  family      = "mono"
  env         = "primary"
  unique_name = "${local.family}${random_id.suffix.hex}"
  tags = {
    repo    = "${local.family}-deploy"
    service = "shared"
  }
  acr_purge_dev_cmd    = "acr purge --filter '*:.*-dev\\..*' --ago 1h"
  acr_purge_stable_cmd = "acr purge '*:^\\d+$' --ago 0d --keep 10"
  acr_purge_schedule   = "0 2 * * *"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.family}-${local.env}"
  location = "northeurope"
  tags     = local.tags
}

resource "azurerm_storage_account" "sa" {
  name                     = local.unique_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}
