variable "db_login" {
  sensitive = true
}

variable "db_password" {
  sensitive = true
}

variable "db_sku" {
  default = "B_Standard_B1ms"
}

variable "db_storage_gb" {
  default = "20"
}

variable "db_address_prefix" {
  default = "10.0.2.0/24"
}

# Network #############################################
resource "azurerm_subnet" "mysql" {
  name                             = "${local.default_resource_name}_mysql_subnet"
  resource_group_name = azurerm_resource_group.default.name
  virtual_network_name  = azurerm_virtual_network.default.name
  address_prefixes          = [var.db_address_prefix]
  service_endpoints        = ["Microsoft.Storage"]
  delegation {
    name = "mysql"
    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_dns_zone" "mysql" {
  name                             = "privatelink.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                                = "${local.default_resource_name}_mysql_vnet_link"
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id           = azurerm_virtual_network.default.id
  resource_group_name    = azurerm_resource_group.default.name
}

resource "azurerm_mysql_flexible_server_firewall_rule" "mysql_allow_ip" {
  name                             = "${local.default_resource_name}_mysql_allow_ip"
  server_name                 = azurerm_mysql_flexible_server.default.name
  resource_group_name = azurerm_resource_group.default.name
  start_ip_address          = var.net_allowed_ip
  end_ip_address            = var.net_allowed_ip
}

# MySQL Flexible Server ###################################
resource "azurerm_mysql_flexible_server" "default" {
  # General configuration
  name                             = local.default_resource_uniquename
  location                         = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  # Administrator credentials
  administrator_login         = var.db_login
  administrator_password = var.db_password

  # Performance configuration
  sku_name   = var.db_sku
  storage {
    auto_grow_enabled = true
    io_scaling_enabled = true
    size_gb                    = var.db_storage_gb
  }

  # Network configuration
  delegated_subnet_id    = azurerm_subnet.mysql.id
  private_dns_zone_id     = azurerm_private_dns_zone.mysql.id

  # Backup and high availability
  backup_retention_days                  = 7
  geo_redundant_backup_enabled  = false

  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql]
}

# Outputs ##############################################
output "mysql_server_fqdn" {
  value = azurerm_mysql_flexible_server.default.fqdn
}

output "mysql_dns_zone" {
  value = azurerm_private_dns_zone.mysql.name
}

output "mysql_public_access" {
  value = azurerm_mysql_flexible_server.default.public_network_access_enabled
}
