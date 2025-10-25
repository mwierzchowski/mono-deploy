locals {
  service      = "devops"
  group_name     = "rg-${var.family}-${local.service}"
  storage_name   = "st${var.family}${local.service}${var.devops.suffix}"
  github_ci_name = "${var.family}-continuous-integration"
}

data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "devops" {
  name = local.group_name
}

data "azurerm_storage_account" "devops" {
  name                = local.storage_name
  resource_group_name = data.azurerm_resource_group.devops.name
}

data "azuread_service_principal" "github_ci" {
  display_name = local.github_ci_name
}
