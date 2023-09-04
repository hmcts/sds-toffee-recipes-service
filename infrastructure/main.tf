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
  app        = "recipe-backend"

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

# secrets for single server (source) - for DMS migration testing only
resource "azurerm_key_vault_secret" "POSTGRES-USER-SOURCE" {
  name         = "recipe-backend-POSTGRES-USER-SOURCE"
  value        = module.single_database_source.user_name
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "POSTGRES-PASS-SOURCE" {
  name         = "recipe-backend-POSTGRES-PASS-SOURCE"
  value        = module.single_database_source.postgresql_password
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "POSTGRES-HOST-SOURCE" {
  name         = "recipe-backend-POSTGRES-HOST-SOURCE"
  value        = module.single_database_source.host_name
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "POSTGRES-PORT-SOURCE" {
  name         = "recipe-backend-POSTGRES-PORT-SOURCE"
  value        = module.single_database_source.postgresql_listen_port
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "POSTGRES-DATABASE-SOURCE" {
  name         = "recipe-backend-POSTGRES-DATABASE-SOURCE"
  value        = module.single_database_source.postgresql_database
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

  common_tags = var.common_tags
  admin_user_object_id = var.jenkins_AAD_objectId
  pgsql_databases = [
    {
      name : "toffee"
    }
  ]

  pgsql_version = "14"
}

# single server (source) - for DMS migration testing only
module "single_database_source" {
  source             = "git@github.com:hmcts/cnp-module-postgres?ref=postgresql_tf"
  product            = var.product
  name               = "${var.product}-v11-source"
  location           = var.location
  env                = var.env
  postgresql_user    = "rhubarbadmin"
  database_name      = "rhubarb-v11"
  postgresql_version = "11"
  subnet_id          = data.azurerm_subnet.postgres.id
  sku_name           = "GP_Gen5_2"
  sku_tier           = "GeneralPurpose"
  storage_mb         = "51200"
  common_tags        = var.common_tags
  subscription       = var.subscription
  key_vault_rg       = "genesis-rg"
  key_vault_name     = "dtssharedservices${var.env}kv"
  business_area      = "SDS"
}
