locals {
  build_github_org  = "mwierzchowski"
  build_github_repo = "mono-jvm"
  # TODO: switch to main when ready
  # build_github_ref  = "refs/heads/main"
  build_github_ref  = "refs/heads/azf-deployment"
}

resource "azuread_application" "gha_acrpush" {
  display_name = "gha-${local.family}-${local.env}"  # keep to avoid replacement
}

resource "azuread_service_principal" "gha_acrpush" {
  client_id = azuread_application.gha_acrpush.client_id
}

resource "azuread_application_federated_identity_credential" "gha_acrpush" {
  application_id = azuread_application.gha_acrpush.id
  display_name   = "gha-${local.build_github_repo}-${replace(local.build_github_ref, "/", "-")}"
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${local.build_github_org}/${local.build_github_repo}:ref:${local.build_github_ref}"
  audiences      = ["api://AzureADTokenExchange"]
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

output "azure_tenant_id" {
  value = data.azuread_client_config.current_gha_acrpush.tenant_id
}
