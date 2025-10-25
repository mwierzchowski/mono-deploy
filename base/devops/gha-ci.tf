locals {
  ci_name = "${var.family}-${var.devops.gha.ci_env}"
}

resource "azuread_application" "app_ci" {
  display_name = local.ci_name
}

resource "azuread_service_principal" "app_ci" {
  client_id = azuread_application.app_ci.client_id
}

resource "azuread_application_federated_identity_credential" "app_ci_env" {
  for_each       = toset(var.devops.gha.ci_repos)
  application_id = azuread_application.app_ci.id
  display_name = "env-${local.ci_name}-${each.value}"
  issuer       = "https://token.actions.githubusercontent.com"
  subject      = "repo:${var.devops.gha.org}/${each.value}:environment:${var.devops.gha.ci_env}"
  audiences    = ["api://AzureADTokenExchange"]
}

resource "azurerm_role_assignment" "app_ci_subscription_reader" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.app_ci.id
}

resource "azurerm_role_assignment" "app_ci_artifacts_owner" {
  scope                = azurerm_storage_account.devops.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azuread_service_principal.app_ci.id
}

resource "azurerm_role_assignment" "app_ci_acr_push" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.app_ci.id
}

output "AZURE_CLIENT_CI_ID" {
  value = azuread_application.app_ci.client_id
}
