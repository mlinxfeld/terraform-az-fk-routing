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
  description = "Azure VM size used for the spoke test VMs."
  default     = "Standard_B1ms"
}

variable "spoke1_vm_private_ip" {
  type        = string
  description = "Static private IP address of the test VM in Spoke1."
  default     = "10.1.1.4"
}

variable "spoke2_vm_private_ip" {
  type        = string
  description = "Static private IP address of the test VM in Spoke2."
  default     = "10.2.1.4"
}

