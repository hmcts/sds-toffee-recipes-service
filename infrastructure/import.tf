import {
  for_each = var.env == "sbox" && var.postgres_major_upgrade_test_enabled ? toset(["sbox"]) : toset([])

  to = module.postgres_major_upgrade_test[0].azurerm_postgresql_flexible_server.pgsql_server
  id = "/subscriptions/a8140a9e-f1b0-481f-a4de-09e2ee23f7ab/resourceGroups/apple-v14-flexible-data-sbox/providers/Microsoft.DBforPostgreSQL/flexibleServers/toffee-pg-major-upgrade-test-sbox"
}