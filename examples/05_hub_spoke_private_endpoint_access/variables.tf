variable "location" {
  type        = string
  description = "Azure region."
  default     = "westeurope"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name."
  default     = "fk-rg"
}

variable "name_prefix" {
  description = "Prefix for storage account name (lowercase only)."
  type        = string
  default     = "fksa"

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.name_prefix)) && length(var.name_prefix) <= 10
    error_message = "name_prefix must be lowercase letters/numbers only and max 10 chars."
  }
}

variable "router_private_ip" {
  type        = string
  description = "Static private IP address of the hub router VM."
  default     = "10.0.1.4"
}

variable "router_vm_size" {
  type        = string
  description = "Azure VM size used for the hub router VM."
  default     = "Standard_B1ms"
}

variable "spoke_vm_size" {
  type        = string
  description = "Azure VM size used for the spoke test VM."
  default     = "Standard_B1ms"
}

variable "spoke2_vm_private_ip" {
  type        = string
  description = "Static private IP address of the test VM in Spoke2."
  default     = "10.2.1.4"
}
