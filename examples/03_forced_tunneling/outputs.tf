output "hub_vnet_id" {
  value = module.vnet_hub.vnet_id
}

output "spoke1_vnet_id" {
  value = module.vnet_spoke1.vnet_id
}

output "spoke2_vnet_id" {
  value = module.vnet_spoke2.vnet_id
}

output "router_vm_id" {
  value = module.router_vm.vm_id
}

output "router_private_ip" {
  value = module.router_vm.vm_private_ip
}

output "router_nsg_id" {
  value = module.nsg_router.id
}

output "spoke1_vm_id" {
  value = module.spoke1_vm.vm_id
}

output "spoke1_vm_private_ip" {
  value = module.spoke1_vm.vm_private_ip
}

output "spoke2_vm_id" {
  value = module.spoke2_vm.vm_id
}

output "spoke2_vm_private_ip" {
  value = module.spoke2_vm.vm_private_ip
}

output "route_tables" {
  value = module.routing.route_table_ids
}

output "peering_ids" {
  value = {
    hub_to_spoke1 = module.peering_hub_spoke1.peering_1_to_2_id
    spoke1_to_hub = module.peering_hub_spoke1.peering_2_to_1_id
    hub_to_spoke2 = module.peering_hub_spoke2.peering_1_to_2_id
    spoke2_to_hub = module.peering_hub_spoke2.peering_2_to_1_id
  }
}

