variable "location" {
  default = "North Europe"
}

variable app_name {
  default = "mono"
}

variable env_name {
  default = "shared"
}

variable "net_allowed_ip" {
  sensitive = true
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

locals {
  default_resource_name = "${var.app_name}_${var.env_name}"
  default_resource_simplename = "${var.app_name}${var.env_name}"
  default_resource_unique_simplename = "${var.app_name}${var.env_name}${random_string.suffix.result}"
  default_resource_unique_fqdn = "${var.app_name}-${var.env_name}-${random_string.suffix.result}"
}

resource "azurerm_resource_group" "default" {
  name     = "${local.default_resource_name}_resources"
  location = var.location
}

output "resource_group_name" {
  value = "${azurerm_resource_group.default.name}"
}
