output "route_table_ids" {
  description = "Map of route table IDs"
  value = {
    for k, v in azurerm_route_table.rt :
    k => v.id
  }
}

output "route_table_names" {
  description = "Map of route table names"
  value = {
    for k, v in azurerm_route_table.rt :
    k => v.name
  }
}