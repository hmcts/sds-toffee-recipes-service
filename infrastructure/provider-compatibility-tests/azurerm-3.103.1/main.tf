terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.103.1"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.9.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id            = var.subscription_id
  skip_provider_registration = true
}

provider "azurerm" {
  features {}

  alias                      = "postgres_network"
  subscription_id            = var.network_subscription_id
  skip_provider_registration = true
}

locals {
  name = "toffee-azurerm3103-provider-test"
}

resource "azurerm_resource_group" "test" {
  count = var.create_test_server ? 1 : 0

  name     = "${local.name}-data-${var.env}"
  location = var.location
  tags     = var.common_tags
}

module "postgresql_flexible" {
  count = var.create_test_server ? 1 : 0

  providers = {
    azurerm.postgres_network = azurerm.postgres_network
  }

  source              = "git@github.com:hmcts/terraform-module-postgresql-flexible?ref=master"
  env                 = var.env
  product             = "toffee"
  component           = "provider-compatibility"
  name                = local.name
  business_area       = "sds"
  location            = var.location
  resource_group_name = azurerm_resource_group.test[0].name
  create_mode         = "Default"

  common_tags                   = var.common_tags
  admin_user_object_id          = var.admin_user_object_id
  enable_read_only_group_access = false
  pgsql_databases = [
    {
      name = "upgrade_validation"
    }
  ]

  pgsql_version     = var.pgsql_version
  pgsql_sku         = var.pgsql_sku
  high_availability = false
  subnet_suffix     = "expanded"
}

variable "create_test_server" {
  description = "Explicitly permits creation of this isolated compatibility test server."
  type        = bool
  default     = false
}

variable "subscription_id" {
  description = "Subscription ID in which to create the isolated test resources."
  type        = string
}

variable "network_subscription_id" {
  description = "Subscription ID containing the Sandbox PostgreSQL delegated subnet."
  type        = string
}

variable "admin_user_object_id" {
  description = "Object ID granted PostgreSQL Entra administration by the module."
  type        = string
}

variable "env" {
  description = "Environment that supplies the Sandbox network naming convention."
  type        = string
  default     = "sbox"
}

variable "location" {
  type    = string
  default = "UK South"
}

variable "pgsql_version" {
  description = "Start at 14, then change only this value to 17 for the upgrade test."
  type        = string
  default     = "14"
}

variable "pgsql_sku" {
  type    = string
  default = "B_Standard_B1ms"
}

variable "common_tags" {
  type = map(string)
  default = {
    "purpose" = "azurerm-provider-compatibility-test"
  }
}