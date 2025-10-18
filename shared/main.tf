locals {
  family      = "mono"
  group       = "shared"
  location    = "northeurope"
  github_repo = "mono-deploy"
  tags = {
    repo    = local.github_repo
    service = local.group
  }
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}

resource "azurerm_resource_group" "tfstate" {
  name     = "rg-${local.family}-${local.group}"
  location = local.location
  tags     = local.tags
}
