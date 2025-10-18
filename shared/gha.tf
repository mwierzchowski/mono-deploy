
locals {
  github_org  = "mwierzchowski"
  github_repo = "mono-jvm"
  github_env  = "ci-artifacts"
}

resource "azuread_application" "gha_ci_artifacts" {
  display_name = "gha-${local.family}-${local.github_env}"
}

resource "azuread_service_principal" "gha_ci_artifacts" {
  client_id = azuread_application.gha_ci_artifacts.client_id
}

resource "azuread_application_federated_identity_credential" "gha_ci_artifacts_env" {
  application_id = azuread_application.gha_ci_artifacts.id
  display_name   = "env-${local.github_env}"
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${local.github_org}/${local.github_repo}:environment:${local.github_env}"
  audiences      = ["api://AzureADTokenExchange"]
}

data "azurerm_subscription" "current" {}

output "mono_github_secrets" {
  value = {
    AZURE_SUBSCRIPTION_ID = data.azurerm_subscription.current.subscription_id
    AZURE_TENANT_ID       = data.azurerm_subscription.current.tenant_id
    AZURE_CLIENT_ID       = azuread_application.gha_ci_artifacts.client_id
  }
}

output "github_ci_environment" {
  value = local.github_env
}