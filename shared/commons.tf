variable "location" {
  default = "North Europe"
}

variable app_name {
  default = "mono"
}

variable env_name {
  default = "shared"
}

locals {
  default_resource_name = "${var.app_name}_${var.env_name}"
  default_resource_simplename = "${var.app_name}${var.env_name}"
}

resource "azurerm_resource_group" "default" {
  name     = "${local.default_resource_name}_resources"
  location = var.location
}

output "resource_group_name" {
  value = "${azurerm_resource_group.default.name}"
}
