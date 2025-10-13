locals {
  tf_env_name = "cd-tf"
}

# App registration & SP used by mono-deploy to run Terraform applies
resource "azuread_application" "gha_tfdeploy" {
  display_name = "gha-tfdeploy-${local.family}-${local.env}"
}

resource "azuread_service_principal" "gha_tfdeploy" {
  client_id = azuread_application.gha_tfdeploy.client_id
}

resource "azuread_application_federated_identity_credential" "gha_tfdeploy_env" {
  application_id = azuread_application.gha_tfdeploy.id
  display_name   = "gha-${local.github_deploy_repo}-environment-${local.tf_env_name}"
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${local.github_org}/${local.github_deploy_repo}:environment:${local.tf_env_name}"
  audiences      = ["api://AzureADTokenExchange"]
  lifecycle {
    prevent_destroy = true
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
