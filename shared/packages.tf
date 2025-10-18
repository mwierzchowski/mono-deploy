resource "azurerm_storage_account" "packages" {
  name                            = "st${local.family}packages${random_id.suffix.hex}"
  resource_group_name             = azurerm_resource_group.shared.name
  location                        = local.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  tags                            = local.tags
}

resource "azurerm_storage_container" "packages" {
  name                  = "packages"
  storage_account_id    = azurerm_storage_account.packages.id
  container_access_type = "private"
}

output "packages_base_url" {
  value = "https://${azurerm_storage_account.packages.name}.blob.core.windows.net/${azurerm_storage_container.packages.name}"
}
