locals {
  artifact_container = "artifacts"
}

resource "azurerm_storage_account" "devops" {
  name                            = var.devops.storage
  resource_group_name             = azurerm_resource_group.devops.name
  location                        = azurerm_resource_group.devops.location
  account_tier                    = var.storage_defaults.tier
  account_replication_type        = var.storage_defaults.replication
  min_tls_version                 = var.storage_defaults.tls_version
  https_traffic_only_enabled      = var.storage_defaults.https_only
  allow_nested_items_to_be_public = var.storage_defaults.nested_public
  tags                            = local.tags
}

resource "azurerm_management_lock" "devops_st_lock" {
  name       = "${local.stack}-st-lock"
  scope      = azurerm_storage_account.devops.id
  lock_level = "CanNotDelete"
  notes      = "Prevent accidental deletion of storage."
}

resource "azurerm_storage_container" "artifacts" {
  name                  = local.artifact_container
  storage_account_id    = azurerm_storage_account.devops.id
  container_access_type = var.storage_defaults.access
}

resource "azurerm_storage_management_policy" "devops_storage_policy" {
  storage_account_id = azurerm_storage_account.devops.id

  rule {
    name    = "delete-dev-after-x-days"
    enabled = true

    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["${azurerm_storage_container.artifacts.name}/"]
      match_blob_index_tag {
        name      = "stage"
        operation = "=="
        value     = "dev"
      }
    }

    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = var.devops.purge.dev_days
      }
    }
  }
}

output "ARTIFACT_STORAGE" {
  value = var.devops.storage
}

output "ARTIFACT_CONTAINER" {
  value = azurerm_storage_container.artifacts.name
}
