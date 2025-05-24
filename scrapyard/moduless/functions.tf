# resource "azurerm_app_service_plan" "example" {
#   name                = "example-app-service-plan"
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name
#   sku {
#     tier = "Dynamic"
#     size = "Y1" # Consumption plan
#   }
# }
#
# resource "azurerm_function_app" "example" {
#   name                       = "example-function-app"
#   location                   = azurerm_resource_group.example.location
#   resource_group_name        = azurerm_resource_group.example.name
#   app_service_plan_id        = azurerm_app_service_plan.example.id
#   storage_account_name       = azurerm_storage_account.example.name
#   storage_account_access_key = azurerm_storage_account.example.primary_access_key
#   version                    = "~4" # Azure Functions version
#
#   app_settings = {
#     FUNCTIONS_WORKER_RUNTIME = "java"
#     JAVA_VERSION             = "11" # Set the Java version
#     WEBSITE_RUN_FROM_PACKAGE = "1"  # Enables deployment via ZIP
#   }
# }
#
# # todo move to outputs
# output "function_app_default_hostname" {
#   value = azurerm_function_app.example.default_hostname
# }