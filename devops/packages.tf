resource "azurerm_storage_container" "packages" {
  name                  = "packages"
  storage_account_id    = azurerm_storage_account.devops.id
  container_access_type = "private"
}

data "azuread_service_principal" "gha_ci_artifacts" {
  display_name = "gha-mono-ci-artifacts"
}

# Allow GitHub Actions (ci-artifacts) to push/pull blobs
resource "azurerm_role_assignment" "gha_ci_artifacts_blob_contrib" {
  scope                = azurerm_storage_container.packages.resource_manager_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_service_principal.gha_ci_artifacts.id
}

output "packages_base_url" {
  value = "https://${azurerm_storage_account.devops.name}.blob.core.windows.net/${azurerm_storage_container.packages.name}"
}
