locals {
  github_org  = "mwierzchowski"
  github_repo = "mono-jvm"
  # TODO replace branch with main
  # github_ref  = "refs/heads/main"  # e.g.: refs/heads/main, refs/tags/v1.2.3, or use 'pull_request'
  github_ref  = "refs/heads/azf-deployment"
}

# App registration that represents GitHub Actions in Azure AD
resource "azuread_application" "gha" {
  display_name = "gha-${local.family}-${local.env}"
}

# Service principal for the app registration
resource "azuread_service_principal" "gha" {
  client_id = azuread_application.gha.client_id
}

# Federated identity: trust GitHub OIDC token from your repo/branch
resource "azuread_application_federated_identity_credential" "gha" {
  application_id        = azuread_application.gha.id
  display_name          = "gha-${local.github_repo}-${replace(local.github_ref, "/", "-")}"
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:${local.github_org}/${local.github_repo}:ref:${local.github_ref}"
  audiences             = ["api://AzureADTokenExchange"]
}

# Allow this principal to push to your existing ACR
resource "azurerm_role_assignment" "acr_push" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.gha.object_id
}

# Useful outputs to copy into GitHub secrets
data "azuread_client_config" "current" {}

output "azure_client_id" {
  value = azuread_application.gha.client_id
}

output "azure_tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}