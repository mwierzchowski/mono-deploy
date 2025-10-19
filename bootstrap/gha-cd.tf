locals {
  github_cd_env  = "cd-terraform"
}

resource "azuread_application" "gha_cd_terraform" {
  display_name = "gha-${local.family}-${local.github_cd_env}"
}

resource "azuread_service_principal" "gha_cd_terraform" {
  client_id = azuread_application.gha_cd_terraform.client_id
}

resource "azuread_application_federated_identity_credential" "gha_env_cd_terraform" {
  application_id = azuread_application.gha_cd_terraform.id
  display_name   = "env-${local.github_cd_env}"
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${local.github_org}/${local.github_repo}:environment:${local.github_cd_env}"
  audiences      = ["api://AzureADTokenExchange"]
}

resource "azurerm_role_assignment" "gha_contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.gha_cd_terraform.id
}

resource "azurerm_role_assignment" "gha_blob_contrib" {
  scope                = azurerm_storage_account.devops.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.gha_cd_terraform.id
}

output "github_cd_terraform_environment" {
  value = local.github_cd_env
}

output "cd_terraform_github_secrets" {
  value = {
    AZURE_CLIENT_ID       = azuread_application.gha_cd_terraform.client_id
    AZURE_TENANT_ID       = data.azurerm_subscription.current.tenant_id
    AZURE_SUBSCRIPTION_ID = data.azurerm_subscription.current.subscription_id
  }
}



