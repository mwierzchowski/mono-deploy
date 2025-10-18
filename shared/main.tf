locals {
  family      = "mono"
  group       = "shared"
  location    = "northeurope"
  tags = {
    repo    = "mono-deploy"
    service = local.group
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "azurerm_resource_group" "shared" {
  name     = "rg-${local.family}-${local.group}"
  location = local.location
  tags     = local.tags
}
