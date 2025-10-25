locals {
  ci_name = "${var.family}-${var.github_actions.ci_env}"
}

resource "azuread_application" "app_ci" {
  display_name = local.ci_name
}

resource "azuread_service_principal" "app_ci" {
  client_id = azuread_application.app_ci.client_id
}

resource "azuread_application_federated_identity_credential" "app_ci_env" {
  for_each       = toset(var.github_actions.ci_repos)
  application_id = azuread_application.app_ci.id
  display_name = "env-${local.ci_name}-${each.value}"
  issuer       = "https://token.actions.githubusercontent.com"
  subject      = "repo:${var.github_actions.org}/${each.value}:environment:${var.github_actions.ci_env}"
  audiences    = ["api://AzureADTokenExchange"]
}

resource "azurerm_role_assignment" "app_ci_subscription_reader" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.app_ci.id
}

output "AZURE_CLIENT_CI_ID" {
  value = azuread_application.app_ci.client_id
}
