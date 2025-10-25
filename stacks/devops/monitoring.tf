locals {
  law = "law-${var.family}-${local.stack}"
}

resource "azurerm_log_analytics_workspace" "devops" {
  name                = local.law
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.devops.law.sku
  retention_in_days   = var.devops.law.retention
  tags                = local.tags
}
