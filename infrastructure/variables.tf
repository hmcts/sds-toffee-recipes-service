variable "product" {
  default = "toffee"
}
variable "component" {}

variable "location" {
  default = "UK South"
}

variable "env" {
}

variable "aks_subscription_id" {
}

variable "subscription" {
}

variable "tenant_id" {}

variable "jenkins_AAD_objectId" {
  description = "(Required) The Azure AD object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies."
}

variable "capacity" {
  default = "1"
}

# thumbprint of the SSL certificate for API gateway tests
variable "api_gateway_test_certificate_thumbprint" {
  # keeping this empty by default, so that no thumbprint will match
  default = ""
}

variable "autoheal" {
  description = "Enabling Proactive Auto Heal for Webapps"
  default     = "True"
}

variable "private_dns_subscription_id" {
  default = "1baf5470-1c3e-40d3-a6f7-74bfbce4b348"
}
variable "common_tags" {
  type = map(string)
}

variable "pgsql_sku" {
  default = "GP_Standard_D2s_v3"
}

variable "postgres_major_upgrade_test_enabled" {
  description = "Creates the isolated Plum PostgreSQL major-version upgrade test server."
  type        = bool
  default     = false
}

variable "postgres_major_upgrade_test_version" {
  description = "PostgreSQL version for the upgrade test server. Set to 14 initially, then 17 for the upgrade test."
  type        = string
  default     = "14"

  validation {
    condition     = contains(["14", "15", "16", "17"], var.postgres_major_upgrade_test_version)
    error_message = "The major-upgrade test version must be PostgreSQL 14, 15, 16, or 17."
  }
}

variable "postgres_major_upgrade_test_subnet_suffix" {
  description = "PostgreSQL delegated subnet suffix for the Plum test server."
  type        = string
  default     = "expanded"

  validation {
    condition     = contains(["expanded", "none"], var.postgres_major_upgrade_test_subnet_suffix)
    error_message = "The PostgreSQL subnet suffix must be expanded or none."
  }
}

# DTSPO-32691: temporarily disabled with the App Service Plan module.
# variable "asp_sku_size" {
#   type        = string
#   description = "SKU size for the App Service Plan (e.g. B1, P1v3)."
#   default     = "B1"
# }
#
# variable "asp_capacity" {
#   description = "Number of workers for the App Service Plan."
#   type        = number
#   default     = 1
# }
