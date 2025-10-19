locals {
  family      = "mono"
  group       = "tfstate"
  location    = "northeurope"
  github_org  = "mwierzchowski"
  github_repo = "mono-deploy"
  tags = {
    repo    = local.github_repo
    service = local.group
  }
}

data "azurerm_subscription" "current" {}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "azurerm_resource_group" "tfstate" {
  name     = "rg-${local.family}-${local.group}"
  location = local.location
  tags     = local.tags
}

resource "azurerm_management_lock" "devops_lock" {
  name       = "lock-${local.group}"
  scope      = azurerm_resource_group.tfstate.id
  lock_level = "CanNotDelete"
  notes      = "Protect Terraform state resources."
}
