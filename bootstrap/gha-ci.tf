locals {
  github_ci_env  = "ci-artifacts"
}

resource "azuread_application" "gha_ci_artifacts" {
  display_name = "gha-${local.family}-${local.github_ci_env}"
}

resource "azuread_service_principal" "gha_ci_artifacts" {
  client_id = azuread_application.gha_ci_artifacts.client_id
}

# Let GHA environment read the subscription
resource "azurerm_role_assignment" "gha_ci_artifacts_reader" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.gha_ci_artifacts.id
}

# Copy-paste-update for other repositories (replace mono-jvm in 2 places)
resource "azuread_application_federated_identity_credential" "gha_env_mono_jvm_ci_artifacts" {
  application_id = azuread_application.gha_ci_artifacts.id
  display_name   = "env-${local.github_ci_env}-mono-jvm"
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${local.github_org}/mono-jvm:environment:${local.github_ci_env}"
  audiences      = ["api://AzureADTokenExchange"]
}

output "ci_artifacts_github_secrets" {
  value = {
    AZURE_CLIENT_ID       = azuread_application.gha_ci_artifacts.client_id
    AZURE_TENANT_ID       = data.azurerm_subscription.current.tenant_id
    AZURE_SUBSCRIPTION_ID = data.azurerm_subscription.current.subscription_id
  }
}
