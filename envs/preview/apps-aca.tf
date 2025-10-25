locals {
  aca_name = "aca-${var.family}-${local.stack}"
  aca_cfg  = yamldecode(file("${path.module}/apps-aca.yaml"))
  aca_apps = {
    for name, cfg in local.aca_cfg.apps :
    name => merge(var.aca_defaults, cfg)
  }
  devops_law   = "law-${var.family}-devops"
}

data "azurerm_log_analytics_workspace" "devops" {
  name                = local.devops_law
  resource_group_name = local.devops_group
}

data "azurerm_container_registry" "devops" {
  name                = var.devops.registry
  resource_group_name = local.devops_group
}

resource "azurerm_container_app_environment" "preview" {
  name                       = local.aca_name
  resource_group_name        = azurerm_resource_group.preview.name
  location                   = azurerm_resource_group.preview.location
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.devops.id
  tags                       = local.tags
}

resource "azurerm_user_assigned_identity" "uami_aca" {
  name                = "uami-${var.family}-${local.stack}-aca"
  resource_group_name = azurerm_resource_group.preview.name
  location            = azurerm_resource_group.preview.location
  tags                = local.tags
}

resource "azurerm_role_assignment" "uami_aca_acr_pull" {
  scope                = data.azurerm_container_registry.devops.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.uami_aca.principal_id
}

resource "azurerm_container_app" "aca_app" {
  for_each = local.aca_apps
  name                         = each.key
  resource_group_name          = azurerm_resource_group.preview.name
  container_app_environment_id = azurerm_container_app_environment.preview.id
  revision_mode                = each.value.revision_mode

  depends_on = [
    azurerm_role_assignment.uami_aca_acr_pull
  ]

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uami_aca.id]
  }

  # Required even if ACR is part of image name (for auth)
  registry {
    server   = "${var.devops.registry}.azurecr.io"
    identity = azurerm_user_assigned_identity.uami_aca.id
  }

  ingress {
    external_enabled = each.value.ingress_external_enabled
    target_port      = each.value.ingress_target_port
    transport        = each.value.ingress_transport

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    container {
      name   = "functions"
      image  = each.value.image
      cpu    = each.value.cpu
      memory = each.value.memory

      # Non-secret env vars from YAML
      dynamic "env" {
        for_each = lookup(each.value, "env", {})
        content {
          name  = env.key
          value = tostring(env.value)
        }
      }

      # TODO Do I need this if I do not deploy more AZFs as images?
      # Shared storage for Azure Functions
      env {
        name  = "AzureWebJobsStorage"
        value = azurerm_storage_account.preview.primary_connection_string
      }
    }

    min_replicas = each.value.min_replicas
    max_replicas = each.value.max_replicas
  }

  tags = {
    repo    = each.value.repository
    service = each.key
  }
}

output "aca_fqdns" {
  value = { for name, app in azurerm_container_app.aca_app : name => app.ingress[0].fqdn }
}
