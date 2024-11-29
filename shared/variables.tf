variable "subscription_id" {
  description = "The Azure subscription ID"
}

variable "location" {
  description = "The Azure region to deploy resources"
  default = "West Central US"
}

variable "app_name"  {
  description = "The name of the application"
  default = "mono"
}

variable "cfg_name"  {
  description = "The name of the configuration module"
  default = "shared"
}
