# Let GHA environment read the subscription
resource "azurerm_role_assignment" "gha_ci_artifacts_reader" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.gha_ci_artifacts.id
}

# Allow GitHub Actions (ci-artifacts) to push/pull blobs
resource "azurerm_role_assignment" "gha_ci_blob_owner" {
  scope                = data.azurerm_storage_account.devops.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azuread_service_principal.gha_ci_artifacts.id
}
