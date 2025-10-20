resource "azurerm_storage_container" "packages" {
  name                  = "packages"
  storage_account_id    = azurerm_storage_account.devops.id
  container_access_type = "private"
}

resource "azurerm_storage_management_policy" "devops_storage_policy" {
  storage_account_id = azurerm_storage_account.devops.id

  rule {
    name    = "delete-dev-after-1-day"
    enabled = true

    filters {
      blob_types  = ["blockBlob"]
      prefix_match = ["packages/"]
      match_blob_index_tag {
        name      = "stage"
        operation = "Equals"
        value     = "dev"
      }
    }

    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 1
      }
    }
  }
}

output "packages_base_url" {
  value = "https://${azurerm_storage_account.devops.name}.blob.core.windows.net/${azurerm_storage_container.packages.name}"
}
