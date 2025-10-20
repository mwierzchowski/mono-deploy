# Allow GitHub Actions (ci-artifacts) read the subscription
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

# Allow GitHub Actions (ci-artifacts) to push/pull images to ACR
resource "azurerm_role_assignment" "gha_ci_acr_push" {
  scope                = data.azurerm_container_registry.devops.id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.gha_ci_artifacts.id
}

# Allow GitHub Actions (cd-terraform) to create users
resource "azurerm_role_assignment" "gha_cd_uaa" {
  scope                = data.azurerm_resource_group.devops.id
  role_definition_name = "User Access Administrator"
  principal_id         = data.azuread_service_principal.gha_cd_terraform.id
}
