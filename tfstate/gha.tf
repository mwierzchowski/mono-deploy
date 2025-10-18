resource "azuread_application" "gha_tf" {
  display_name = "gha-${local.family}-${local.github_env}"
}

resource "azuread_service_principal" "gha_tf" {
  client_id = azuread_application.gha_tf.client_id
}

resource "azuread_application_federated_identity_credential" "gha_env_cd_tf" {
  application_id = azuread_application.gha_tf.id
  display_name   = "env-${local.github_env}"
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${local.github_org}/${local.github_repo}:environment:${local.github_env}"
  audiences      = ["api://AzureADTokenExchange"]
}

data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "gha_contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.gha_tf.id
}

resource "azurerm_role_assignment" "gha_blob_contrib" {
  scope                = azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.gha_tf.id
}

output "mono_deploy_github_secrets" {
  value = {
    AZURE_CLIENT_ID       = azuread_application.gha_tf.client_id
    AZURE_TENANT_ID       = data.azurerm_subscription.current.tenant_id
    AZURE_SUBSCRIPTION_ID = data.azurerm_subscription.current.subscription_id
  }
}

output "github_cd_environment" {
  value = local.github_env
}
