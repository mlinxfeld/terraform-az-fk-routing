# Router inside NIC NSG
module "nsg_router_inside" {
  source = "github.com/mlinxfeld/terraform-az-fk-nsg"

  name                = "fk-nsg-router-inside"
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
      name                         = "allow-outbound-to-spokes"
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

# Router outside NIC NSG
module "nsg_router_outside" {
  source = "github.com/mlinxfeld/terraform-az-fk-nsg"

  name                = "fk-nsg-router-outside"
  location            = azurerm_resource_group.fk_rg.location
  resource_group_name = azurerm_resource_group.fk_rg.name

  rules = [
    {
      name                       = "allow-outbound-internet"
      priority                   = 110
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
      description                = "Allow outbound Internet traffic from the router VM."
    }
  ]
}
