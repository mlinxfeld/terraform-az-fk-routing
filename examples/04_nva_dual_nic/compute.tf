# Router VM in Hub
module "router_vm" {
  source = "github.com/mlinxfeld/terraform-az-fk-compute"

  name                = "fk-router-vm"
  location            = azurerm_resource_group.fk_rg.location
  resource_group_name = azurerm_resource_group.fk_rg.name

  deployment_mode = "vm"
  vm_size         = var.router_vm_size

  ssh_public_key = tls_private_key.public_private_key_pair.public_key_openssh
  lb_attachment  = null

  network_interfaces = {
    outside = {
      subnet_id                     = module.vnet_hub.subnet_ids["fk-subnet-hub-outside"]
      private_ip_address_allocation = "Static"
      private_ip_address            = var.router_outside_private_ip
      enable_ip_forwarding          = true
      attach_nsg_to_nic             = true
      nsg_id                        = module.nsg_router_outside.id
      primary                       = true
    }
    inside = {
      subnet_id                     = module.vnet_hub.subnet_ids["fk-subnet-hub-inside"]
      private_ip_address_allocation = "Static"
      private_ip_address            = var.router_inside_private_ip
      enable_ip_forwarding          = true
      attach_nsg_to_nic             = true
      nsg_id                        = module.nsg_router_inside.id
      primary                       = false
    }
  }

  custom_data = base64encode(<<-EOF
    #cloud-config
    packages:
      - iptables-persistent
      - curl
    write_files:
      - path: /usr/local/bin/configure-router.sh
        permissions: "0755"
        content: |
          #!/bin/sh
          set -eu
          OUTSIDE_IFACE=$(ip route show default | awk '/default/ {print $5; exit}')
          INSIDE_IFACE=$(ip -o addr show | awk '/10\.0\.1\./ {print $2; exit}')
          INSIDE_GATEWAY=$(ip route show dev "$INSIDE_IFACE" default | awk '/default/ {print $3; exit}')
          if [ -z "$INSIDE_GATEWAY" ]; then
            INSIDE_GATEWAY=$(ip route show | awk '/10\.0\.1\.0\/24/ && /via/ {print $3; exit}')
          fi
          sysctl -w net.ipv4.conf.all.rp_filter=0
          sysctl -w net.ipv4.conf.default.rp_filter=0
          sysctl -w net.ipv4.conf."$INSIDE_IFACE".rp_filter=0
          sysctl -w net.ipv4.conf."$OUTSIDE_IFACE".rp_filter=0
          if [ -n "$INSIDE_GATEWAY" ]; then
            ip route replace 10.1.0.0/16 via "$INSIDE_GATEWAY" dev "$INSIDE_IFACE"
            ip route replace 10.2.0.0/16 via "$INSIDE_GATEWAY" dev "$INSIDE_IFACE"
          fi
          iptables -A FORWARD -s 10.1.0.0/16 -d 10.2.0.0/16 -j ACCEPT
          iptables -A FORWARD -s 10.2.0.0/16 -d 10.1.0.0/16 -j ACCEPT
          iptables -A FORWARD -s 10.1.0.0/16 -o "$OUTSIDE_IFACE" -j ACCEPT
          iptables -A FORWARD -s 10.2.0.0/16 -o "$OUTSIDE_IFACE" -j ACCEPT
          iptables -A FORWARD -d 10.1.0.0/16 -i "$OUTSIDE_IFACE" -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
          iptables -A FORWARD -d 10.2.0.0/16 -i "$OUTSIDE_IFACE" -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
          iptables -t nat -A POSTROUTING -s 10.1.0.0/16 -o "$OUTSIDE_IFACE" -j MASQUERADE
          iptables -t nat -A POSTROUTING -s 10.2.0.0/16 -o "$OUTSIDE_IFACE" -j MASQUERADE
          netfilter-persistent save
    runcmd:
      - sysctl -w net.ipv4.ip_forward=1
      - sed -i '/^net.ipv4.ip_forward/d' /etc/sysctl.conf
      - echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
      - sed -i '/^net.ipv4.conf.all.rp_filter/d' /etc/sysctl.conf
      - sed -i '/^net.ipv4.conf.default.rp_filter/d' /etc/sysctl.conf
      - echo 'net.ipv4.conf.all.rp_filter=0' >> /etc/sysctl.conf
      - echo 'net.ipv4.conf.default.rp_filter=0' >> /etc/sysctl.conf
      - /usr/local/bin/configure-router.sh
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
      - curl
      - dnsutils
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
      - curl
      - dnsutils
    EOF
  )
}
