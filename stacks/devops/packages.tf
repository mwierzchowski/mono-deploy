# locals {
#   pkg_container_name = "packages"
# }
#
# resource "azurerm_storage_container" "packages" {
#   name                  = local.pkg_container_name
#   storage_account_id    = data.azurerm_storage_account.devops.id
#   container_access_type = "private"
# }
#
# # Allow GitHub Actions (ci-artifacts) to push/pull blobs
# resource "azurerm_role_assignment" "github_ci_packages_owner" {
#   scope                = data.azurerm_storage_account.devops.id
#   role_definition_name = "Storage Blob Data Owner"
#   principal_id         = data.azuread_service_principal.github_ci.id
# }
#
# resource "azurerm_storage_management_policy" "devops_storage_policy" {
#   storage_account_id = data.azurerm_storage_account.devops.id
#
#   rule {
#     name    = "delete-dev-after-1-day"
#     enabled = true
#
#     filters {
#       blob_types  = ["blockBlob"]
#       prefix_match = ["${azurerm_storage_container.packages.name}/"]
#       match_blob_index_tag {
#         name      = "stage"
#         operation = "=="
#         value     = "dev"
#       }
#     }
#
#     actions {
#       base_blob {
#         delete_after_days_since_modification_greater_than = 1
#       }
#     }
#   }
# }
#
# output "packages_base_url" {
#   value = "https://${data.azurerm_storage_account.devops.name}.blob.core.windows.net/${azurerm_storage_container.packages.name}"
# }
