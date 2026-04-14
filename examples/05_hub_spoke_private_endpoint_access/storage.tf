module "storage" {
  source = "github.com/mlinxfeld/terraform-az-fk-storage"

  name                = local.storage_account_name
  resource_group_name = azurerm_resource_group.fk_rg.name
  location            = azurerm_resource_group.fk_rg.location

  account_tier               = "Standard"
  account_replication_type   = "LRS"
  account_kind               = "StorageV2"
  access_tier                = "Hot"
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  public_network_access_enabled = false
  enable_network_rules          = false

  create_containers = false
  containers        = {}

  create_file_shares = false
}
