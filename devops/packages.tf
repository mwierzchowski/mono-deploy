resource "azurerm_storage_container" "packages" {
  name                  = "packages"
  storage_account_id    = data.azurerm_storage_account.devops.id
  container_access_type = "private"
}

output "packages_base_url" {
  value = "https://${data.azurerm_storage_account.devops.name}.blob.core.windows.net/${azurerm_storage_container.packages.name}"
}
