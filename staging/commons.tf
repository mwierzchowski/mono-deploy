variable "location" {
  default = "West Central US"
}

variable app_name {
  default = "mono"
}

variable env_name {
  default = "staging"
}

variable "allowed_ip" {
  sensitive = true
}

locals {
  default_resource_name = "${var.app_name}_${var.env_name}"
  default_resource_simplename = "${var.app_name}${var.env_name}"
}

resource "azurerm_resource_group" "default" {
  name     = local.default_resource_name
  location = var.location
}

output "resource_group_name" {
  value = "${azurerm_resource_group.default.name}"
}
