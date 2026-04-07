# HUB
module "vnet_hub" {
  source = "github.com/mlinxfeld/terraform-az-fk-vnet"

  name                = "fk-vnet-hub"
  location            = azurerm_resource_group.fk_rg.location
  resource_group_name = azurerm_resource_group.fk_rg.name
  address_space       = ["10.0.0.0/16"]

  subnets = {
    fk-hub-subnet = {
      name             = "fk-hub-subnet"
      address_prefixes = ["10.0.1.0/24"]
    }
  }
}

# SPOKE 1
module "vnet_spoke1" {
  source = "github.com/mlinxfeld/terraform-az-fk-vnet"

  name                = "fk-vnet-spoke1"
  location            = azurerm_resource_group.fk_rg.location
  resource_group_name = azurerm_resource_group.fk_rg.name
  address_space       = ["10.1.0.0/16"]

  subnets = {
    fk-subnet-spoke1 = {
      name             = "fk-subnet-spoke1"
      address_prefixes = ["10.1.1.0/24"]
    }
  }
}

# SPOKE 2
module "vnet_spoke2" {
  source = "github.com/mlinxfeld/terraform-az-fk-vnet"

  name                = "fk-vnet-spoke2"
  location            = azurerm_resource_group.fk_rg.location
  resource_group_name = azurerm_resource_group.fk_rg.name
  address_space       = ["10.2.0.0/16"]

  subnets = {
    fk-subnet-spoke2 = {
      name             = "fk-subnet-spoke2"
      address_prefixes = ["10.2.1.0/24"]
    }
  }
}

# HUB <-> SPOKE 1
module "peering_hub_spoke1" {
  source = "github.com/mlinxfeld/terraform-az-fk-vnet-peering"

  resource_group_name = azurerm_resource_group.fk_rg.name

  vnet_1_id   = module.vnet_hub.vnet_id
  vnet_1_name = module.vnet_hub.vnet_name
  vnet_2_id   = module.vnet_spoke1.vnet_id
  vnet_2_name = module.vnet_spoke1.vnet_name

  allow_forwarded_traffic = true
}

# HUB <-> SPOKE 2
module "peering_hub_spoke2" {
  source = "github.com/mlinxfeld/terraform-az-fk-vnet-peering"

  resource_group_name = azurerm_resource_group.fk_rg.name

  vnet_1_id   = module.vnet_hub.vnet_id
  vnet_1_name = module.vnet_hub.vnet_name
  vnet_2_id   = module.vnet_spoke2.vnet_id
  vnet_2_name = module.vnet_spoke2.vnet_name

  allow_forwarded_traffic = true
}

# Routing module
module "routing" {
  source = "../../"

  resource_group_name = azurerm_resource_group.fk_rg.name

  route_tables = {
    rt-spoke1 = {
      location = azurerm_resource_group.fk_rg.location

      routes = [
        {
          name           = "to-spoke2-via-hub"
          address_prefix = "10.2.0.0/16"
          next_hop_type  = "VirtualAppliance"
          next_hop_ip    = module.router_vm.vm_private_ip
        },
        {
          name           = "default-to-internet-via-hub"
          address_prefix = "0.0.0.0/0"
          next_hop_type  = "VirtualAppliance"
          next_hop_ip    = module.router_vm.vm_private_ip
        }
      ]

      subnet_ids = [
        module.vnet_spoke1.subnet_ids["fk-subnet-spoke1"]
      ]
    }

    rt-spoke2 = {
      location = azurerm_resource_group.fk_rg.location

      routes = [
        {
          name           = "to-spoke1-via-hub"
          address_prefix = "10.1.0.0/16"
          next_hop_type  = "VirtualAppliance"
          next_hop_ip    = module.router_vm.vm_private_ip
        },
        {
          name           = "default-to-internet-via-hub"
          address_prefix = "0.0.0.0/0"
          next_hop_type  = "VirtualAppliance"
          next_hop_ip    = module.router_vm.vm_private_ip
        }
      ]

      subnet_ids = [
        module.vnet_spoke2.subnet_ids["fk-subnet-spoke2"]
      ]
    }
  }
}

