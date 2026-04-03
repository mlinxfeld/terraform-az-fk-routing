locals {
  route_tables = var.route_tables

  # Flatten routes
  routes = flatten([
    for rt_name, rt in local.route_tables : [
      for route in rt.routes : {
        key     = "${rt_name}-${route.name}"
        rt_name = rt_name
        route   = route
      }
    ]
  ])

  # Flatten subnet associations
  associations = flatten([
    for rt_name, rt in local.route_tables : [
       for idx, subnet_id in rt.subnet_ids : {
        key       = "${rt_name}-${idx}"
        rt_name   = rt_name
        subnet_id = subnet_id
      }
    ]
  ])

}

# Route Tables
resource "azurerm_route_table" "rt" {
  for_each = local.route_tables

  name                = each.key
  location            = each.value.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Routes
resource "azurerm_route" "routes" {
  for_each = {
    for r in local.routes : r.key => r
  }

  name                   = each.value.route.name
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.rt[each.value.rt_name].name
  address_prefix         = each.value.route.address_prefix
  next_hop_type          = each.value.route.next_hop_type
  next_hop_in_ip_address = try(each.value.route.next_hop_ip, null)
}

# Subnet Associations
resource "azurerm_subnet_route_table_association" "assoc" {
  for_each = {
    for a in local.associations : a.key => a
  }

  subnet_id      = each.value.subnet_id
  route_table_id = azurerm_route_table.rt[each.value.rt_name].id
}