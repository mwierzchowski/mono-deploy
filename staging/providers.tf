variable "subscription_id" {
  sensitive = true
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
 backend "azurerm" {
   resource_group_name  = "mono_shared"
   storage_account_name = "monoshared5gxr2n"
   container_name             = "tfstate"
   key                                  = "staging/terraform.tfstate"
 }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

