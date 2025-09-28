module "smerek" {
  source = "git::https://github.com/mwierzchowski/mono-jvm.git//projects/smerek/deploy?ref=azf-deployment"
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.apps_env.id
  acr_login_server             = azurerm_container_registry.acr.login_server
  acr_id                       = azurerm_container_registry.acr.id
  uami_id                      = azurerm_user_assigned_identity.acr_pull.id
  storage                      = azurerm_storage_account.sa.primary_connection_string
}

output "smerek_fqdn" {
  value = module.smerek.fqdn
}