locals {
  acr_purge_dev_cmd    = "acr purge --filter '*:.*-dev\\..*' --ago 1h"
  acr_purge_stable_cmd = "acr purge '*:^\\d+$' --ago 0d --keep 10"
  acr_purge_schedule   = "0 2 * * *"
}

resource "azurerm_container_registry" "acr" {
  name                = "acr${local.family}${local.group}${random_id.suffix.hex}"
  resource_group_name = azurerm_resource_group.devops.name
  location            = azurerm_resource_group.devops.location
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

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}
