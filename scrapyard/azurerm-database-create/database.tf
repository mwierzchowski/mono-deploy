variable "db_server_id" {
  sensitive = true
}

# Create Database in PostgreSQL Server
resource "azurerm_postgresql_flexible_server_database" "default" {
  name       = local.default_resource_name
  server_id = var.db_server_id
  collation  = "en_US.utf8"
  charset   = "UTF8"

  lifecycle {
    prevent_destroy = true
  }
}

# Outputs #############################################
output "db_server_id" {
  value = azurerm_postgresql_flexible_server_database.default.name
}