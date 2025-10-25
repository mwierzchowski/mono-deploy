locals {
  cd_name = "${var.family}-${var.devops.gha.cd_env}"
  tfstate_group = "rg-${var.family}-tfstate"
}

data "azurerm_storage_account" "tfstate" {
  name                = var.tfstate.storage
  resource_group_name = local.tfstate_group
}

resource "azuread_application" "app_cd" {
  display_name = local.cd_name
}

resource "azuread_service_principal" "app_cd" {
  client_id = azuread_application.app_cd.client_id
}

resource "azuread_application_federated_identity_credential" "app_cd_env" {
  application_id = azuread_application.app_cd.id
  display_name   = "env-${local.cd_name}"
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.devops.gha.org}/${var.repo}:environment:${var.devops.gha.cd_env}"
  audiences      = ["api://AzureADTokenExchange"]
}

resource "azurerm_role_assignment" "app_cd_tfstate_contributor" {
  scope                = data.azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.app_cd.id
}

resource "azurerm_role_assignment" "app_cd_subscription_contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.app_cd.id
}

resource "azurerm_role_assignment" "app_cd_user_admin" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "User Access Administrator"
  principal_id         = azuread_service_principal.app_cd.id
}

output "AZURE_CLIENT_CD_ID" {
  value = azuread_application.app_cd.client_id
}
