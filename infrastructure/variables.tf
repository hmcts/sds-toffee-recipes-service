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

variable "service_criticality" {
  description = "Service criticality rating from 1-5."
  type        = number
  default     = 1
}

variable "asp_sku_size" {
  type        = string
  description = "SKU size for the App Service Plan (e.g. B1, P1v3)."
  default     = "B1"
}

variable "asp_capacity" {
  description = "Number of workers for the App Service Plan."
  type        = number
  default     = 1
}
