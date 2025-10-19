locals {
  azf_cfg = yamldecode(file("${path.module}/apps-azf.yaml"))

  # Globals/defaults for ALL Functions in this env
  azf_defaults = {
    plan_os_type                = "Linux"  # Linux/Windows
    plan_sku_name               = "Y1"     # Y1 (Consumption), EP1.. (Premium), S1.. (Dedicated)
    functions_extension_version = "~4"
    worker_runtime              = "java"
    java_version                = "21"
  }

  azf_apps = local.azf_cfg.apps
}

data "azurerm_storage_container" "packages" {
  name                 = "packages"
  storage_account_name = data.azurerm_storage_account.devops.name
}

# One shared plan for the env; uses locals (no hard-coding)
resource "azurerm_service_plan" "azf_plan" {
  name                = "plan-${local.family}-${local.group}-azf"
  resource_group_name = azurerm_resource_group.preview.name
  location            = azurerm_resource_group.preview.location

  os_type  = local.azf_defaults.plan_os_type
  sku_name = local.azf_defaults.plan_sku_name
  tags     = local.tags
}

# Per-app identity (clean RBAC)
resource "azurerm_user_assigned_identity" "azf" {
  for_each            = local.azf_apps
  name                = "uami-${each.key}-${local.group}"
  resource_group_name = azurerm_resource_group.preview.name
  location            = azurerm_resource_group.preview.location
  tags                = local.tags
}

# Allow reading the ZIPs from the packages container
resource "azurerm_role_assignment" "azf_pkg_reader" {
  for_each             = local.azf_apps
  # scope                = data.azurerm_storage_container.packages.id
  scope                = data.azurerm_storage_container.packages.resource_manager_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.azf[each.key].principal_id
}

# Linux Function Apps (run-from-package)
resource "azurerm_linux_function_app" "azf_app" {
  for_each            = local.azf_apps

  name                = each.key
  resource_group_name = azurerm_resource_group.preview.name
  location            = azurerm_resource_group.preview.location
  service_plan_id     = azurerm_service_plan.azf_plan.id

  # Host storage for Functions runtime
  storage_account_name       = azurerm_storage_account.preview.name
  storage_account_access_key = azurerm_storage_account.preview.primary_access_key

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.azf[each.key].id]
  }

  app_settings = merge(
    {
      FUNCTIONS_EXTENSION_VERSION                  = local.azf_defaults.functions_extension_version
      FUNCTIONS_WORKER_RUNTIME                     = local.azf_defaults.worker_runtime
      WEBSITE_RUN_FROM_PACKAGE                     = each.value.package_url
      WEBSITE_RUN_FROM_PACKAGE_BLOB_MI_RESOURCE_ID = azurerm_user_assigned_identity.azf[each.key].id
    },
    lookup(each.value, "app_settings", {})
  )

  site_config {
    application_stack {
      java_version = local.azf_defaults.java_version
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
