locals {
  pkg_env_name = "ci-packages"
}

resource "azuread_application" "gha_pkgpush" {
  display_name = "gha-pkgpush-${local.family}-${local.env}"
}

resource "azuread_service_principal" "gha_pkgpush" {
  client_id = azuread_application.gha_pkgpush.client_id
}

resource "azuread_application_federated_identity_credential" "gha_pkgpush_env" {
  application_id = azuread_application.gha_pkgpush.id
  display_name   = "gha-${local.github_build_repo}-environment-${local.pkg_env_name}"
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${local.github_org}/${local.github_build_repo}:environment:${local.pkg_env_name}"
  audiences      = ["api://AzureADTokenExchange"]
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_role_assignment" "pkg_blob_contributor" {
  scope                = azurerm_storage_container.packages.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.gha_pkgpush.object_id
}

data "azuread_client_config" "current_gha_pkgpush" {}

output "pkgpush_azure_client_id" {
  value = azuread_application.gha_pkgpush.client_id
}

output "pkgpush_azure_tenant_id" {
  value = data.azuread_client_config.current_gha_pkgpush.tenant_id
}
