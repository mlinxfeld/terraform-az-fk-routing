module "private_dns" {
  source = "github.com/mlinxfeld/terraform-az-fk-private-dns"

  resource_group_name    = azurerm_resource_group.fk_rg.name
  private_dns_zone_names = [local.dns_zone_name]

  vnet_links = {
    spoke1-link = {
      vnet_id              = module.vnet_spoke1.vnet_id
      registration_enabled = false
    }
    spoke2-link = {
      vnet_id              = module.vnet_spoke2.vnet_id
      registration_enabled = false
    }
  }
}
