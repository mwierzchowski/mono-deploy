variable "db_server_name" {
  # TODO
  default = "mono-shared-33dv1j.postgres.database.azure.com"
}

variable "db_server_id" {
  sensitive = true
}

variable "db_login" {
  sensitive = true
}

variable "db_password" {
  sensitive = true
}

# TODO Configuration
# PostgreSQL Flexible Server (Assumed to already exist)
data "azurerm_postgresql_flexible_server" "default" {
  name                             = "mono-shared-33dv1j"
  resource_group_name = "mono_shared_resources"
}

# Create Database in PostgreSQL Server ######################
resource "azurerm_postgresql_flexible_server_database" "default" {
  name       = local.default_resource_name
  server_id = data.azurerm_postgresql_flexible_server.default.id
  collation  = "en_US.utf8"
  charset   = "UTF8"

  lifecycle {
    prevent_destroy = true
  }
}

# Create User and Grant Privileges
resource "null_resource" "postgresql_create_user" {
  provisioner "local-exec" {
    environment = {
      PGPASSWORD = var.db_password
    }
    command = <<EOT
    docker run --rm postgres:16 \
      psql -h ${var.db_server_name} \
        -U monoadmin \
        -d postgres \
        -c "CREATE USER mono WITH PASSWORD '${var.db_password}';"

    docker run --rm postgres:16 \
      psql -h ${var.db_server_name} \
        -U monoadmin \
        -d postgres \
        -c "GRANT ALL PRIVILEGES ON DATABASE mono_integration TO mono;"
  EOT
  }
}

# Outputs #############################################
output "db_server_id" {
  value = azurerm_postgresql_flexible_server_database.default.name
}