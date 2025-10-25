# locals {
#   law_name = "law-${var.family}-${local.service}"
# }
#
# resource "azurerm_log_analytics_workspace" "devops" {
#   name                = local.law_name
#   location            = data.azurerm_resource_group.devops.location
#   resource_group_name = data.azurerm_resource_group.devops.name
#   sku                 = "PerGB2018"
#   retention_in_days   = 30
#   tags                = data.azurerm_resource_group.devops.tags
# }
