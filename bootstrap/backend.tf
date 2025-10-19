resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.devops.id
  container_access_type = "private"
}

output "tf_backend" {
  value = {
    resource_group_name  = azurerm_resource_group.devops.name
    storage_account_name = azurerm_storage_account.devops.name
    container_name       = azurerm_storage_container.tfstate.name
  }
}
