locals {
  family      = "mono"
  github_org  = "mwierzchowski"
  github_env  = "ci-artifacts"
}

data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "devops" {
  name = "rg-mono-devops"
}

data "azurerm_storage_account" "devops" {
  name                = "stmonodevopsb1e7a48d"
  resource_group_name = "rg-mono-devops"
}

data "azuread_service_principal" "gha_cd_terraform" {
  display_name = "gha-mono-cd-terraform"
}