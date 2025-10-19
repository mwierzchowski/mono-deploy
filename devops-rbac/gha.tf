resource "azuread_application" "gha_ci_artifacts" {
  display_name = "gha-${local.family}-${local.github_env}"
}

resource "azuread_service_principal" "gha_ci_artifacts" {
  client_id = azuread_application.gha_ci_artifacts.client_id
}

# Copy-paste-update for other repositories (replace mono-jvm in 2 places)
resource "azuread_application_federated_identity_credential" "gha_env_mono_jvm_ci_artifacts" {
  application_id = azuread_application.gha_ci_artifacts.id
  display_name   = "env-${local.github_env}-mono-jvm"
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${local.github_org}/mono-jvm:environment:${local.github_env}"
  audiences      = ["api://AzureADTokenExchange"]
}

output "ci_artifacts_github_secrets" {
  value = {
    AZURE_CLIENT_ID       = azuread_application.gha_ci_artifacts.client_id
    AZURE_TENANT_ID       = data.azurerm_subscription.current.tenant_id
    AZURE_SUBSCRIPTION_ID = data.azurerm_subscription.current.subscription_id
  }
}
