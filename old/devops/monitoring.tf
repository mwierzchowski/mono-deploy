resource "azurerm_log_analytics_workspace" "devops" {
  name                = "law-${local.family}-${local.group}"
  location            = azurerm_resource_group.devops.location
  resource_group_name = azurerm_resource_group.devops.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}
