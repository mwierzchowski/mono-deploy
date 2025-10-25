locals {
  artifact_container = "artifacts"
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
