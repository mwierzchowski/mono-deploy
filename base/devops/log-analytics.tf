locals {
  law = "law-${var.family}-${local.stack}"
}

resource "azurerm_log_analytics_workspace" "devops" {
  name                = local.law
  location            = azurerm_resource_group.devops.location
  resource_group_name = azurerm_resource_group.devops.name
  sku                 = var.devops.law_sku
  retention_in_days   = var.devops.law_retention
  tags                = local.tags
}
