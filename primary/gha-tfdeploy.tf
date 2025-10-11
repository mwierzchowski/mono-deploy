locals {
  deploy_github_org  = "mwierzchowski"
  deploy_github_repo = "mono-deploy"
  deploy_github_ref_main = "refs/heads/main"
  deploy_github_ref_feature  = "refs/heads/aca-workflow"
}

# App registration & SP used by mono-deploy to run Terraform applies
resource "azuread_application" "gha_tfdeploy" {
  display_name = "gha-tfdeploy-${local.family}-${local.env}"
}

resource "azuread_service_principal" "gha_tfdeploy" {
  client_id = azuread_application.gha_tfdeploy.client_id
}

# Federated credential for mono-deploy main branch
resource "azuread_application_federated_identity_credential" "gha_tfdeploy_main" {
  application_id = azuread_application.gha_tfdeploy.id
  display_name   = "gha-${local.deploy_github_repo}-${replace(local.deploy_github_ref_main, "/", "-")}"
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${local.deploy_github_org}/${local.deploy_github_repo}:ref:${local.deploy_github_ref_main}"
  audiences      = ["api://AzureADTokenExchange"]
  lifecycle {
    prevent_destroy = true
    ignore_changes  = [display_name]
  }
}

# Federated credential for mono-deploy feature branch
resource "azuread_application_federated_identity_credential" "gha_tfdeploy_feature" {
  application_id = azuread_application.gha_tfdeploy.id
  display_name   = "gha-${local.deploy_github_repo}-${replace(local.deploy_github_ref_feature, "/", "-")}"
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${local.deploy_github_org}/${local.deploy_github_repo}:ref:${local.deploy_github_ref_feature}"
  audiences      = ["api://AzureADTokenExchange"]
  lifecycle {
    prevent_destroy = true
    ignore_changes  = [display_name]
  }
}

# Least-privilege scope for Terraform: the environment RG
resource "azurerm_role_assignment" "tfdeploy_rg_contributor" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.gha_tfdeploy.object_id
}

data "azuread_client_config" "current_gha_tfdeploy" {}

output "tfdeploy_azure_client_id" {
  value = azuread_application.gha_tfdeploy.client_id
}

output "tfdeploy_azure_tenant_id" {
  value = data.azuread_client_config.current_gha_tfdeploy.tenant_id
}
