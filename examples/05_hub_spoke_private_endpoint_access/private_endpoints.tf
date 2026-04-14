module "private_endpoint_blob" {
  source = "github.com/mlinxfeld/terraform-az-fk-private-endpoint"

  name                = local.private_endpoint_name
  location            = azurerm_resource_group.fk_rg.location
  resource_group_name = azurerm_resource_group.fk_rg.name
  subnet_id           = module.vnet_spoke1.subnet_ids["fk-subnet-spoke1"]

  private_connection_resource_id = module.storage.storage_account_id
  subresource_names              = ["blob"]
  is_manual_connection           = false

  private_dns_zone_group_name = "default"
  private_dns_zone_ids        = [module.private_dns.private_dns_zone_ids[local.dns_zone_name]]

  depends_on = [
    module.private_dns
  ]
}
