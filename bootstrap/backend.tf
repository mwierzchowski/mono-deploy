resource "azurerm_resource_group" "tfstate" {
  name     = "rg-${local.family}-${local.group}"
  location = local.location
  tags     = local.tags
}

resource "azurerm_management_lock" "devops_lock" {
  name       = "lock-${local.group}"
  scope      = azurerm_resource_group.tfstate.id
  lock_level = "CanNotDelete"
  notes      = "Protect Terraform state resources."
}

resource "azurerm_storage_account" "tfstate" {
  name                            = "st${local.family}${local.group}${random_id.suffix.hex}"
  resource_group_name             = azurerm_resource_group.tfstate.name
  location                        = azurerm_resource_group.tfstate.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  tags                            = local.tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

output "tf_backend" {
  value = {
    resource_group_name  = azurerm_resource_group.tfstate.name
    storage_account_name = azurerm_storage_account.tfstate.name
    container_name       = azurerm_storage_container.tfstate.name
  }
}
