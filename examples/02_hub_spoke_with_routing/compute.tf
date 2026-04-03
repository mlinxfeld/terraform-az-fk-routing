# Router VM in Hub
module "router_vm" {
  source = "github.com/mlinxfeld/terraform-az-fk-compute"

  name                = "fk-router-vm"
  location            = azurerm_resource_group.fk_rg.location
  resource_group_name = azurerm_resource_group.fk_rg.name
  subnet_id           = module.vnet_hub.subnet_ids["fk-hub-subnet"]

  deployment_mode = "vm"
  vm_size         = var.router_vm_size

  ssh_public_key                = tls_private_key.public_private_key_pair.public_key_openssh
  enable_ip_forwarding          = true
  private_ip_address_allocation = "Static"
  private_ip_address            = var.router_private_ip
  attach_nsg_to_nic             = true
  nsg_id                        = module.nsg_router.id
  lb_attachment                 = null

  custom_data = base64encode(<<-EOF
    #cloud-config
    runcmd:
      - sysctl -w net.ipv4.ip_forward=1
      - sed -i '/^net.ipv4.ip_forward/d' /etc/sysctl.conf
      - echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
    EOF
  )
}

# Test VM in Spoke1
module "spoke1_vm" {
  source = "github.com/mlinxfeld/terraform-az-fk-compute"

  name                = "fk-spoke1-vm"
  location            = azurerm_resource_group.fk_rg.location
  resource_group_name = azurerm_resource_group.fk_rg.name
  subnet_id           = module.vnet_spoke1.subnet_ids["fk-subnet-spoke1"]

  deployment_mode = "vm"
  vm_size         = var.spoke_vm_size

  ssh_public_key                = tls_private_key.public_private_key_pair.public_key_openssh
  private_ip_address_allocation = "Static"
  private_ip_address            = var.spoke1_vm_private_ip
  lb_attachment                 = null

  custom_data = base64encode(<<-EOF
    #cloud-config
    packages:
      - iputils-ping
      - traceroute
    EOF
  )
}

# Test VM in Spoke2
module "spoke2_vm" {
  source = "github.com/mlinxfeld/terraform-az-fk-compute"

  name                = "fk-spoke2-vm"
  location            = azurerm_resource_group.fk_rg.location
  resource_group_name = azurerm_resource_group.fk_rg.name
  subnet_id           = module.vnet_spoke2.subnet_ids["fk-subnet-spoke2"]

  deployment_mode = "vm"
  vm_size         = var.spoke_vm_size

  ssh_public_key                = tls_private_key.public_private_key_pair.public_key_openssh
  private_ip_address_allocation = "Static"
  private_ip_address            = var.spoke2_vm_private_ip
  lb_attachment                 = null

  custom_data = base64encode(<<-EOF
    #cloud-config
    packages:
      - iputils-ping
      - traceroute
    EOF
  )
}

