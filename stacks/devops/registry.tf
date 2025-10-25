# locals {
#   acr_name             = "acr${var.family}${local.service}${var.devops.suffix}"
#   acr_purge_dev_cmd    = "acr purge --filter '*:.*-dev\\..*' --ago 1h"
#   acr_purge_stable_cmd = "acr purge '*:^\\d+$' --ago 0d --keep 10"
#   acr_purge_schedule   = "0 2 * * *"
# }
#
# resource "azurerm_container_registry" "acr" {
#   name                = local.acr_name
#   resource_group_name = data.azurerm_resource_group.devops.name
#   location            = data.azurerm_resource_group.devops.location
#   sku                 = "Basic"
#   admin_enabled       = false
#   tags                = data.azurerm_resource_group.devops.tags
# }
#
# # Allow GitHub Actions (ci-artifacts) to push/pull images to ACR
# resource "azurerm_role_assignment" "github_ci_acr_push" {
#   scope                = azurerm_container_registry.acr.id
#   role_definition_name = "AcrPush"
#   principal_id         = data.azuread_service_principal.github_ci.id
# }
#
# resource "azurerm_container_registry_task" "acr_purge" {
#   name                  = "task-acr-purge"
#   container_registry_id = azurerm_container_registry.acr.id
#   is_system_task        = false
#   tags                  = data.azurerm_resource_group.devops.tags
#
#   platform {
#     os = "Linux"
#   }
#
#   encoded_step {
#     task_content = <<-YAML
#       version: v1.1.0
#       steps:
#         - cmd: ${local.acr_purge_dev_cmd}
#         - cmd: ${local.acr_purge_stable_cmd}
#       YAML
#   }
#
#   timer_trigger {
#     enabled  = true
#     name     = "scheduled"
#     schedule = local.acr_purge_schedule
#   }
# }
#
# output "acr_login_server" {
#   value = azurerm_container_registry.acr.login_server
# }
