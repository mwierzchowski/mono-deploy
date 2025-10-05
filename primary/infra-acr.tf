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
