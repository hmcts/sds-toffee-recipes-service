import {
  for_each = var.env == "sbox" && var.postgres_major_upgrade_test_enabled ? {
    sbox = "/subscriptions/a8140a9e-f1b0-481f-a4de-09e2ee23f7ab/resourceGroups/apple-v14-flexible-data-sbox/providers/Microsoft.DBforPostgreSQL/flexibleServers/toffee-pg-major-upgrade-test-sbox/administrators/3c52c98b-07a3-4a97-92b9-298e86bb1ca9"
  } : {}

  to = module.postgres_major_upgrade_test[0].azurerm_postgresql_flexible_server_active_directory_administrator.pgsql_adadmin
  id = each.value
}

import {
  for_each = var.env == "sbox" && var.postgres_major_upgrade_test_enabled ? {
    sbox = "/subscriptions/a8140a9e-f1b0-481f-a4de-09e2ee23f7ab/resourceGroups/apple-v14-flexible-data-sbox/providers/Microsoft.DBforPostgreSQL/flexibleServers/toffee-pg-major-upgrade-test-sbox/administrators/5356a0e7-324e-4efa-970b-4b4aec3f0ba3"
  } : {}

  to = module.postgres_major_upgrade_test[0].azurerm_postgresql_flexible_server_active_directory_administrator.pgsql_principal_admin[0]
  id = each.value
}
