# Confirm no other state manages this server and align the resource group before applying.
# The existing server is in Apple; the module currently targets Toffee.
import {
  for_each = var.env == "sbox" && var.postgres_major_upgrade_test_enabled ? {
    sbox = "/subscriptions/a8140a9e-f1b0-481f-a4de-09e2ee23f7ab/resourceGroups/apple-v14-flexible-data-sbox/providers/Microsoft.DBforPostgreSQL/flexibleServers/toffee-pg-major-upgrade-test-sbox"
  } : {}

  to = module.postgres_major_upgrade_test[0].azurerm_postgresql_flexible_server.pgsql_server
  id = each.value
}
