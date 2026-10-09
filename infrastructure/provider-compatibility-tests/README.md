# AzureRM PostgreSQL Provider Compatibility Tests

These two Terraform roots test the PostgreSQL Flexible Server module against
AzureRM `3.103.1` and `4.37.0`. They are intentionally separate from the
service `infrastructure` root because Terraform can select only one version of
`hashicorp/azurerm` per root module.

Both roots are disabled by default and have no remote backend configured. Do
not apply them with local state. Before testing, configure a distinct approved
remote backend for each provider version and supply the required variables.

For each root:

1. Set `create_test_server = true` and apply with `pgsql_version = "14"`.
2. Record the generated `.terraform.lock.hcl` and the creation plan.
3. Change only `pgsql_version` to `"17"`.
4. Inspect the plan. A `~` update for the Flexible Server proves an in-place
   upgrade; `-/+` proves replacement.
5. Apply only after review, then destroy the isolated test resources.

The test roots create their own uniquely named resource group and server. They
must use a subscription with access to the Sandbox `postgres-expanded` subnet.