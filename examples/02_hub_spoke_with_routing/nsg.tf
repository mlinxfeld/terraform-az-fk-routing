# Router NSG
module "nsg_router" {
  source = "github.com/mlinxfeld/terraform-az-fk-nsg"

  name                = "fk-nsg-router"
  location            = azurerm_resource_group.fk_rg.location
  resource_group_name = azurerm_resource_group.fk_rg.name

  rules = [
    {
      name                       = "allow-spokes-inbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefixes    = ["10.1.0.0/16", "10.2.0.0/16"]
      destination_address_prefix = "*"
      description                = "Allow forwarded traffic from both spoke VNets to the router VM."
    },
    {
      name                         = "allow-spokes-outbound"
      priority                     = 110
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "*"
      source_port_range            = "*"
      destination_port_range       = "*"
      source_address_prefix        = "*"
      destination_address_prefixes = ["10.1.0.0/16", "10.2.0.0/16"]
      description                  = "Allow forwarded traffic from the router VM back to both spoke VNets."
    }
  ]
}

