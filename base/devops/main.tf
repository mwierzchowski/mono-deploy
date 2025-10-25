locals {
  stack = "devops"
  group = "rg-${var.family}-${local.stack}"
  tags = {
    repo  = var.repo
    stack = local.stack
  }
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "devops" {
  name     = local.group
  location = var.location
  tags     = local.tags
}

resource "azurerm_storage_account" "devops" {
  name                            = var.devops.storage
  resource_group_name             = azurerm_resource_group.devops.name
  location                        = azurerm_resource_group.devops.location
  account_tier                    = var.storage.tier
  account_replication_type        = var.storage.replication
  min_tls_version                 = var.storage.tls_version
  https_traffic_only_enabled      = var.storage.https_only
  allow_nested_items_to_be_public = var.storage.nested_public
  tags                            = local.tags
}

output "AZURE_SUBSCRIPTION_ID" {
  value = data.azurerm_subscription.current.subscription_id
}

output "AZURE_TENANT_ID" {
  value = data.azurerm_subscription.current.tenant_id
}

output "XXX_MONO_DEPLOY_SECRETS" {
  value = "https://github.com/mwierzchowski/mono-deploy/settings/secrets/actions"
}

output "XXX_MONO_JVM_SECRETS" {
  value = "https://github.com/mwierzchowski/mono-jvm/settings/secrets/actions"
}

output "XXX_MONO_JVM_VARS" {
  value = "https://github.com/mwierzchowski/mono-jvm/settings/variables/actions"
}
