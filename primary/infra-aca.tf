resource "azurerm_log_analytics_workspace" "la" {
  name                = "log-analytics"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

resource "azurerm_container_app_environment" "apps_env" {
  name                       = "container-apps"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.la.id
  tags                       = local.tags
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.la.id
}

output "container_app_environment_id" {
  value = azurerm_container_app_environment.apps_env.id
}
