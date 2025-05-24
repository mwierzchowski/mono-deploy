
resource "azurerm_resource_group" "mono" {
  name     = "rg_mono_${var.env_name}"
  location = var.location
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_storage_account" "mono" {
  name                                  = "monostorage${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.mono.name
  location                              = azurerm_resource_group.mono.location
  account_tier                      = "Standard"
  account_replication_type = "LRS"
}
