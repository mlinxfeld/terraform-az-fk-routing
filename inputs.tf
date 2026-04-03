variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "route_tables" {
  description = "Map of route tables with routes and subnet associations"
  type = map(object({
    location = string

    routes = optional(list(object({
      name           = string
      address_prefix = string
      next_hop_type  = string
      next_hop_ip    = optional(string)
    })), [])

    subnet_ids = optional(list(string), [])
  }))
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}