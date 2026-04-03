output "vnet_id" {
  value = module.vnet.vnet_id
}

output "subnet_id" {
  value = module.vnet.subnet_ids["fk-subnet"]
}

output "route_tables" {
  value = module.routing.route_table_ids
}