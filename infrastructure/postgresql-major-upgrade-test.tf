module "postgres_major_upgrade_test" {
  count = var.env == "sbox" && var.postgres_major_upgrade_test_enabled ? 1 : 0

  providers = {
    azurerm.postgres_network = azurerm.postgres_network
  }

  source              = "git@github.com:hmcts/terraform-module-postgresql-flexible?ref=master"
  env                 = var.env
  product             = var.product
  name                = "toffee-pg-major-upgrade-test"
  component           = var.component
  business_area       = "sds"
  location            = var.location
  resource_group_name = module.postgresql_flexible.resource_group_name

  common_tags          = var.common_tags
  admin_user_object_id = var.jenkins_AAD_objectId
  pgsql_databases = [
    {
      name = "upgrade_validation"
    }
  ]

  pgsql_version     = var.postgres_major_upgrade_test_version
  pgsql_sku         = var.pgsql_sku
  high_availability = false
  subnet_suffix     = var.postgres_major_upgrade_test_subnet_suffix
}