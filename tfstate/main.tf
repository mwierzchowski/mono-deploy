locals {
  family      = "mono"
  res_name    = "tfstate"
  location    = "northeurope"
  github_org  = "mwierzchowski"
  github_repo = "mono-deploy"
  github_env  = "cd-tf"
  tags = {
    repo    = local.github_repo
    service = local.res_name
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
  name     = "rg-${local.family}-${local.res_name}"
  location = local.location
  tags     = local.tags
}
