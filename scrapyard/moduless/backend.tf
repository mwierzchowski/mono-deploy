resource "azurerm_storage_container" "tfstate" {
  name                               = "monotfstate${var.env_name}"
  storage_account_id  = azurerm_storage_account.mono.id
  container_access_type = "private"
}

#  Disable on provisioning from scratch
terraform {
  backend "azurerm" {
    resource_group_name  = "rg_mono_dev"
    storage_account_name = "monostoragezh1l6s"
    container_name             = "monotfstatedev"
    key                                  = "terraform.tfstate"
  }
}