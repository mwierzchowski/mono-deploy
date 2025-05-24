variable "subscription_id" {
  description = "The Azure subscription ID"
}

variable "location" {
  description = "The Azure region to deploy resources"
  default = "West Central US"
}

variable "env_name"  {
  description = "The name of the environment"
  default = "dev"
}
