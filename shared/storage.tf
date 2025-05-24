variable "storage_tier" {
    default = "Standard"
}

variable "storage_replication" {
    default = "LRS"
}

resource "azurerm_storage_account" "default" {
  name                                  = local.default_resource_unique_simplename
  resource_group_name      = azurerm_resource_group.default.name
  location                              = azurerm_resource_group.default.location
  account_tier                      = var.storage_tier
  account_replication_type = var.storage_replication
}

resource "azurerm_storage_container" "tfstate" {
  name                               = "tfstate"
  storage_account_id       = azurerm_storage_account.default.id
  container_access_type = "private"
}

output "storage_account_name" {
  value = azurerm_storage_account.default.name
}
