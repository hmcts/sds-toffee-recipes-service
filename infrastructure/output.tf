# this variable will be accessible to tests as API_GATEWAY_URL environment variable
output "api_gateway_url" {
  value = "https://core-api-mgmt-${var.env}.azure-api.net/${local.api_base_path}"
}

output "postgres_major_upgrade_test" {
  value = var.postgres_major_upgrade_test_enabled ? {
    instance_id                 = module.postgres_major_upgrade_test[0].instance_id
    fqdn                        = module.postgres_major_upgrade_test[0].fqdn
    is_enrolled_in_backup_vault = module.postgres_major_upgrade_test[0].is_enrolled_in_backup_vault
    backup_instance_id          = module.postgres_major_upgrade_test[0].backup_instance_id
    backup_instance_name        = module.postgres_major_upgrade_test[0].backup_instance_name
  } : null
}

output "postgres_major_upgrade_test_restore_instance_id" {
  value = var.postgres_major_upgrade_test_restore_enabled ? module.postgres_major_upgrade_test_restore[0].instance_id : null
}

# DTSPO-32691: temporarily disabled with the App Service Plan module.
# output "app_service_plan_id" {
#   description = "Resource ID of the toffee App Service Plan."
#   value       = module.app_service_plan.asp_id
# }
