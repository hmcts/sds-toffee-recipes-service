provider "azurerm" {
  features {}
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
  value        = module.recipe-database.user_name
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "POSTGRES-PASS" {
  name         = "recipe-backend-POSTGRES-PASS"
  value        = module.recipe-database.postgresql_password
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "POSTGRES_HOST" {
  name         = "recipe-backend-POSTGRES-HOST"
  value        = module.recipe-database.host_name
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "POSTGRES_PORT" {
  name         = "recipe-backend-POSTGRES-PORT"
  value        = module.recipe-database.postgresql_listen_port
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "POSTGRES_DATABASE" {
  name         = "recipe-backend-POSTGRES-DATABASE"
  value        = module.recipe-database.postgresql_database
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

module "recipe-database" {
  source             = "git@github.com:hmcts/cnp-module-postgres?ref=postgresql_tf"
  product            = var.product
  name               = "${var.product}-v11"
  location           = var.location
  env                = var.env
  postgresql_user    = "rhubarbadmin"
  database_name      = "rhubarb-v11"
  postgresql_version = "11"
  subnet_id          = data.azurerm_subnet.postgres.id
  sku_name           = "GP_Gen5_2"
  sku_tier           = "GeneralPurpose"
  storage_mb         = "51200"
  common_tags        = module.tags.common_tags
  subscription       = var.subscription
  key_vault_rg       = "genesis-rg"
  key_vault_name     = "dtssharedservices${var.env}kv"
  business_area      = "SDS"
}


module "tags" {
  source      = "git::https://github.com/hmcts/terraform-module-common-tags.git?ref=master"
  environment = lower(var.env)
  product     = var.product
  builtFrom   = var.builtFrom
}
