variable "db_login" {
  sensitive = true
}

variable "db_password" {
  sensitive = true
}

variable "db_sku" {
  default = "B_Standard_B1ms"
}

variable "db_storage_mb" {
  default = "32768"
}

variable "db_storage_tier" {
  default = "P4"
}

variable "db_version" {
  default = "16"
}

variable "db_zone" {
  default = "1"
}

# Network #############################################
resource "azurerm_postgresql_flexible_server_firewall_rule" "postgresql_allow_ip" {
  name                   = "${local.default_resource_name}_postgresql_allow_ip"
  server_id             = azurerm_postgresql_flexible_server.default.id
  start_ip_address = var.net_allowed_ip
  end_ip_address   = var.net_allowed_ip
}

# MySQL Flexible Server ###################################
resource "azurerm_postgresql_flexible_server" "default" {
  # General configuration
  name                             = local.default_resource_unique_fqdn
  resource_group_name = azurerm_resource_group.default.name
  location                         = azurerm_resource_group.default.location
  version                          = var.db_version

  # Administrator credentials
  administrator_login                       = var.db_login
  administrator_password               = var.db_password
  public_network_access_enabled = true

  # Performance configuration
  sku_name    = var.db_sku
  storage_mb = var.db_storage_mb
  storage_tier = var.db_storage_tier
  auto_grow_enabled = true

  # Backup and high availability
  zone                                                = var.db_zone
  backup_retention_days                  = 7
  geo_redundant_backup_enabled  = false
}

# Outputs ##############################################
output "postgresql_server_fqdn" {
  value = azurerm_postgresql_flexible_server.default.fqdn
}
