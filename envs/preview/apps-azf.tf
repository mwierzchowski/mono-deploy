locals {
  azf_plan = "asp-${var.family}-${local.stack}-azf"
  azf_cfg  = yamldecode(file("${path.module}/apps-azf.yaml"))
}

data "azurerm_storage_account" "devops" {
  name                = var.devops.storage
  resource_group_name = local.devops_group
}

resource "azurerm_service_plan" "preview" {
  name                = local.azf_plan
  resource_group_name = azurerm_resource_group.preview.name
  location            = azurerm_resource_group.preview.location
  os_type             = var.azf_defaults.plan_os_type
  sku_name            = var.azf_defaults.plan_sku_name
  tags                = local.tags
}

resource "azurerm_user_assigned_identity" "uami_azf" {
  name                = "uami-${var.family}-${local.stack}-azf"
  resource_group_name = azurerm_resource_group.preview.name
  location            = azurerm_resource_group.preview.location
  tags                = local.tags
}

resource "azurerm_role_assignment" "uami_azf_artifacts_reader" {
  scope                = data.azurerm_storage_account.devops.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.uami_azf.principal_id
}

# Linux Function Apps (run-from-package)
resource "azurerm_linux_function_app" "azf_app" {
  for_each            = local.azf_cfg.apps

  name                = each.key
  resource_group_name = azurerm_resource_group.preview.name
  location            = azurerm_resource_group.preview.location
  service_plan_id     = azurerm_service_plan.preview.id

  # Host storage for Functions runtime
  storage_account_name       = azurerm_storage_account.preview.name
  storage_account_access_key = azurerm_storage_account.preview.primary_access_key

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uami_azf.id]
  }

  app_settings = merge(
    {
      FUNCTIONS_EXTENSION_VERSION                  = var.azf_defaults.functions_extension_version
      FUNCTIONS_WORKER_RUNTIME                     = var.azf_defaults.worker_runtime
      WEBSITE_RUN_FROM_PACKAGE                     = each.value.package_url
      WEBSITE_RUN_FROM_PACKAGE_BLOB_MI_RESOURCE_ID = azurerm_user_assigned_identity.uami_azf.id
    },
    lookup(each.value, "app_settings", {})
  )

  site_config {
    application_stack {
      java_version = var.azf_defaults.java_version
    }
  }

  tags = {
    repo    = each.value.repository
    service = each.key
  }
}

output "azf_hostnames" {
  value = { for n, a in azurerm_linux_function_app.azf_app : n => a.default_hostname }
}
