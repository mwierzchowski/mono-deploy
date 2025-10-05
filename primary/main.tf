resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  family      = "mono"
  env         = "primary"
  unique_name = "${local.family}${random_id.suffix.hex}"
  tags = {
    repo    = "${local.family}-deploy"
    service = "shared"
  }
  acr_purge_dev_cmd    = "acr purge --filter '*:.*-dev\\..*' --ago 1h"
  acr_purge_stable_cmd = "acr purge --filter '*:^\\d+$' --ago 0d --keep 10"
  acr_purge_schedule   = "0 2 * * *"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.family}-${local.env}"
  location = "northeurope"
  tags     = local.tags
}

resource "azurerm_storage_account" "sa" {
  name                     = local.unique_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}

resource "azurerm_container_registry" "acr" {
  name                = local.unique_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = local.tags
}

resource "azurerm_container_registry_task" "acr_purge" {
  name                  = "task-acr-purge"
  container_registry_id = azurerm_container_registry.acr.id
  is_system_task        = false
  tags                  = local.tags
  platform {
    os = "Linux"
  }
  encoded_step {
    task_content = <<-YAML
      version: v1.1.0
      steps:
        - cmd: ${local.acr_purge_dev_cmd}
        - cmd: ${local.acr_purge_stable_cmd}
      YAML
  }
  timer_trigger {
    enabled  = true
    name     = "scheduled"
    schedule = local.acr_purge_schedule
  }
}

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

resource "azurerm_user_assigned_identity" "acr_pull" {
  name                = "uami-acr-pull"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.acr_pull.principal_id
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}
