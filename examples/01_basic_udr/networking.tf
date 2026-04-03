# VNet (using your module)
module "vnet" {
  source = "github.com/mlinxfeld/terraform-az-fk-vnet"

  name                = "fk-vnet-udr"
  location            = azurerm_resource_group.fk_rg.location
  resource_group_name = azurerm_resource_group.fk_rg.name
  address_space       = ["10.0.0.0/16"]

  subnets = {
    fk-subnet = {
      name             = "fk-subnet"
      address_prefixes = ["10.0.1.0/24"]
    }
  }
}

# Routing module
module "routing" {
  #source = "github.com/mlinxfeld/terraform-az-fk-routing"
  source = "../../"
  
  resource_group_name = azurerm_resource_group.fk_rg.name

  route_tables = {
    "rt-basic" = {
      location = azurerm_resource_group.fk_rg.location

      routes = [
        {
          name           = "default-to-internet"
          address_prefix = "0.0.0.0/0"
          next_hop_type  = "Internet"
        }
      ]

      subnet_ids = [
        module.vnet.subnet_ids["fk-subnet"]
      ]
    }
  }
}