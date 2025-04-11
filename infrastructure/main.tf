provider "azurerm" {
  features {}
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
  alias                      = "postgres_network"
  subscription_id            = var.aks_subscription_id
}

locals {
  app = "recipe-backend"

  create_api = var.env != "preview" && var.env != "spreview"

  # list of the thumbprints of the SSL certificates that should be accepted by the API (gateway)
  allowed_certificate_thumbprints = [
    # API tests
    var.api_gateway_test_certificate_thumbprint,
    "29390B7A235C692DACD93FA0AB90081867177BEC"
  ]

  thumbprints_in_quotes     = formatlist("&quot;%s&quot;", local.allowed_certificate_thumbprints)
  thumbprints_in_quotes_str = join(",", local.thumbprints_in_quotes)
  api_policy                = replace(file("template/api-policy.xml"), "ALLOWED_CERTIFICATE_THUMBPRINTS", local.thumbprints_in_quotes_str)
  api_base_path             = "${var.product}-recipes-api"
  shared_infra_rg           = "${var.product}-shared-infrastructure-${var.env}"
  vault_name                = "${var.product}si-${var.env}"
}

data "azurerm_subnet" "postgres" {
  name                 = "iaas"
  resource_group_name  = "ss-${var.env}-network-rg"
  virtual_network_name = "ss-${var.env}-vnet"
}

data "azurerm_key_vault" "key_vault" {
  name                = local.vault_name
  resource_group_name = local.shared_infra_rg
}

resource "azurerm_key_vault_secret" "POSTGRES-USER" {
  name         = "recipe-backend-POSTGRES-USER"
  value        = module.postgresql_flexible.username
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "POSTGRES-PASS" {
  name         = "recipe-backend-POSTGRES-PASS"
  value        = module.postgresql_flexible.password
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "POSTGRES_HOST" {
  name         = "recipe-backend-POSTGRES-HOST"
  value        = module.postgresql_flexible.fqdn
  key_vault_id = data.azurerm_key_vault.key_vault.id
}


resource "azurerm_key_vault_secret" "POSTGRES_DATABASE" {
  name         = "recipe-backend-POSTGRES-DATABASE"
  value        = "toffee"
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "POSTGRES_DATABASE-SOURCE2" {
  name         = "recipe-backend-POSTGRES-DATABASE-SOURCE2"
  value        = "toffee"
  key_vault_id = data.azurerm_key_vault.key_vault.id
}
resource "azurerm_key_vault_secret" "POSTGRES_DATABASE-DESTINATION" {
  name         = "recipe-backend-POSTGRES-DATABASE-DESTINATION"
  value        = "toffee"
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

module "postgresql_flexible" {
  providers = {
    azurerm.postgres_network = azurerm.postgres_network
  }

  source        = "git@github.com:hmcts/terraform-module-postgresql-flexible?ref=master"
  env           = var.env
  product       = var.product
  name          = "${var.product}-v14-flexible"
  component     = var.component
  business_area = "sds"
  location      = var.location
  create_mode   = var.env == "sbox" ? "Default" : "Update"

  common_tags          = var.common_tags
  admin_user_object_id = var.jenkins_AAD_objectId
  pgsql_databases = [
    {
      name : "toffee"
    }
  ]

  pgsql_version = "15"
  pgsql_sku     = var.pgsql_sku
}

resource "azurerm_postgresql_flexible_server" "postgresql_flexible_server_temp_restore" {
  count = var.env == "stg" ? 1 : 0

  lifecycle {
    ignore_changes = [
      # Ignore changes to the point_in_time_restore_time_in_utc attribute
      point_in_time_restore_time_in_utc,
    ]
  }

  name                              = "${var.product}-v14-flexible-restore-temp-stg"
  resource_group_name               = module.postgresql_flexible.resource_group_name
  delegated_subnet_id               = "/subscriptions/74dacd4f-a248-45bb-a2f0-af700dc4cf68/resourceGroups/ss-stg-network-rg/providers/Microsoft.Network/virtualNetworks/ss-stg-vnet/subnets/postgresql"
  public_network_access_enabled     = false
  location                          = var.location
  zone                              = 3
  sku_name                          = var.pgsql_sku
  create_mode                       = "PointInTimeRestore"
  point_in_time_restore_time_in_utc = timeadd(timestamp(), "-24h")
  source_server_id                  = module.postgresql_flexible.instance_id
  storage_mb                        = 65536
  tags                              = var.common_tags
}

resource "azurerm_postgresql_flexible_server" "postgresql_flexible_server_restore" {
  count = var.env == "stg" ? 1 : 0

  lifecycle {
    ignore_changes = [
      # Ignore changes to the point_in_time_restore_time_in_utc attribute
      point_in_time_restore_time_in_utc,
    ]
  }

  name                              = "${var.product}-v14-flexible-restore-stg"
  resource_group_name               = module.postgresql_flexible.resource_group_name
  public_network_access_enabled     = false
  location                          = var.location
  sku_name                          = var.pgsql_sku
  create_mode                       = "PointInTimeRestore"
  point_in_time_restore_time_in_utc = timeadd(timestamp(), "-10m")
  source_server_id                  = azurerm_postgresql_flexible_server.postgresql_flexible_server_temp_restore[0].id
  storage_mb                        = 65536
  tags                              = var.common_tags
}
