resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  family     = "mono"
  repo       = "${local.family}-deploy"
  env        = "primary"
  uniqueName = "${local.family}${random_id.suffix.hex}"
  tags = {
    env  = local.env
    repo = local.repo
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.family}-${local.env}"
  location = "northeurope"
  tags     = { repo = local.repo }
}

resource "azurerm_storage_account" "sa" {
  name                     = local.uniqueName
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = merge(local.tags, { service = "shared" })
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}

resource "azurerm_container_registry" "acr" {
  name                = local.uniqueName
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = merge(local.tags, { service = "shared" })
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}
