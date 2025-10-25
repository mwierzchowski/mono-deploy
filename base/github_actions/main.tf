locals {
  tfstate_group = "rg-${var.family}-tfstate"
}

data "azurerm_subscription" "current" {}

data "azurerm_storage_account" "tfstate" {
  name                = var.tfstate.storage
  resource_group_name = local.tfstate_group
}

output "AZURE_SUBSCRIPTION_ID" {
  value = data.azurerm_subscription.current.subscription_id
}

output "AZURE_TENANT_ID" {
  value = data.azurerm_subscription.current.tenant_id
}
