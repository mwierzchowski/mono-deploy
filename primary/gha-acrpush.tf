locals {
  acr_env_name = "ci-acr"
}

resource "azuread_application" "gha_acrpush" {
  display_name = "gha-${local.family}-${local.env}"
}

resource "azuread_service_principal" "gha_acrpush" {
  client_id = azuread_application.gha_acrpush.client_id
}

resource "azuread_application_federated_identity_credential" "gha_acrpush_env" {
  application_id = azuread_application.gha_acrpush.id
  display_name   = "gha-${local.github_build_repo}-environment-${local.acr_env_name}"
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${local.github_org}/${local.github_build_repo}:environment:${local.acr_env_name}"
  audiences      = ["api://AzureADTokenExchange"]
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_role_assignment" "acrpush_sp_role" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.gha_acrpush.object_id
}

data "azuread_client_config" "current_gha_acrpush" {}

output "acrpush_azure_client_id" {
  value = azuread_application.gha_acrpush.client_id
}

output "acrpush_azure_tenant_id" {
  value = data.azuread_client_config.current_gha_acrpush.tenant_id
}
