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
