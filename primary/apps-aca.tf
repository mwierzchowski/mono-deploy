locals {
  aca_cfg = yamldecode(file("${path.module}/apps-aca.yaml"))

  # Central defaults (overridable per app in YAML)
  aca_default = {
    cpu                       = 0.25
    memory                    = "0.5Gi"
    min_replicas              = 0
    max_replicas              = 1
    ingress_external_enabled  = true
    ingress_target_port       = 80
    ingress_transport         = "auto"
    revision_mode             = "Single"
    registry_server           = azurerm_container_registry.acr.login_server
  }

  # Merge defaults with app-specific config
  aca_apps = {
    for name, cfg in local.aca_cfg.apps :
    name => merge(local.aca_default, cfg)
  }
}

resource "azurerm_container_app" "aca_app" {
  for_each = local.aca_apps

  name                         = each.key
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.apps_env.id
  revision_mode                = each.value.revision_mode

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.acr_pull.id]
  }

  # Required even if ACR is part of image name (for auth)
  registry {
    server   = each.value.registry_server
    identity = azurerm_user_assigned_identity.acr_pull.id
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

      # Shared storage for Azure Functions
      env {
        name  = "AzureWebJobsStorage"
        value = azurerm_storage_account.sa.primary_connection_string
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

# Useful outputs: FQDNs per app
output "aca_fqdns" {
  value = { for name, app in azurerm_container_app.aca_app : name => app.ingress[0].fqdn }
}