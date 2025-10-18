locals {
  family      = "mono"
  location    = "northeurope"
  github_org  = "mwierzchowski"
  github_repo = "mono-deploy"
  tags = {
    repo    = local.github_repo
    service = "tfstate"
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
  name     = "rg-${local.family}-tfstate"
  location = local.location
  tags     = local.tags
}
