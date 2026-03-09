# this variable will be accessible to tests as API_GATEWAY_URL environment variable
output "api_gateway_url" {
  value = "https://core-api-mgmt-${var.env}.azure-api.net/${local.api_base_path}"
}

output "app_service_plan_id" {
  description = "Resource ID of the toffee App Service Plan."
  value       = module.app_service_plan.asp_id
}

output "app_service_plan_identity_principal_id" {
  description = "Principal ID of the system-assigned managed identity on the toffee App Service Plan."
  value       = module.app_service_plan.asp_identity_principal_id
}
