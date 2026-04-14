locals {
  storage_account_name  = "${var.name_prefix}${random_string.suffix.result}"
  dns_zone_name         = "privatelink.blob.core.windows.net"
  private_endpoint_fqdn = "${local.storage_account_name}.blob.core.windows.net"
  private_endpoint_name = "${local.storage_account_name}-pe-blob"
}
