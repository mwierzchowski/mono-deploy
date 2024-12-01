variable "subscription_id" {
  description = "The Azure subscription ID"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "mono_shared_resources"
    storage_account_name = "monoshared33dv1j"
    container_name             = "tfstate"
    key                                  = "shared/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
