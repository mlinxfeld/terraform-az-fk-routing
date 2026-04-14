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

output "spoke2_vm_id" {
  value = module.spoke2_vm.vm_id
}

output "spoke2_vm_private_ip" {
  value = module.spoke2_vm.vm_private_ip
}

output "spoke2_vm_principal_id" {
  value = module.spoke2_vm.vm_principal_id
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

output "storage_account_id" {
  value = module.storage.storage_account_id
}

output "private_endpoint_id" {
  value = module.private_endpoint_blob.private_endpoint_id
}

output "private_endpoint_private_ip" {
  value = length(module.private_endpoint_blob.private_ip_addresses) > 0 ? module.private_endpoint_blob.private_ip_addresses[0] : null
}

output "private_endpoint_fqdn" {
  value = local.private_endpoint_fqdn
}

output "private_dns_zone_name" {
  value = module.private_dns.private_dns_zone_names[0]
}

output "role_assignment_id" {
  value = module.rbac.role_assignment_id
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
