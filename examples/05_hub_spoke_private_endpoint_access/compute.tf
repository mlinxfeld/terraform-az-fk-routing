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

# Test VM in Spoke2
module "spoke2_vm" {
  source = "github.com/mlinxfeld/terraform-az-fk-compute"

  name                = "fk-spoke2-vm"
  location            = azurerm_resource_group.fk_rg.location
  resource_group_name = azurerm_resource_group.fk_rg.name
  subnet_id           = module.vnet_spoke2.subnet_ids["fk-subnet-spoke2"]

  deployment_mode = "vm"
  vm_size         = var.spoke_vm_size
  identity_type   = "SystemAssigned"

  ssh_public_key                = tls_private_key.public_private_key_pair.public_key_openssh
  private_ip_address_allocation = "Static"
  private_ip_address            = var.spoke2_vm_private_ip
  lb_attachment                 = null

  custom_data = base64encode(<<-EOF
    #cloud-config
    package_update: true
    packages:
      - ca-certificates
      - apt-transport-https
      - lsb-release
      - gnupg
      - iputils-ping
      - traceroute
      - curl
      - dnsutils
    write_files:
      - path: /usr/local/bin/blob-proof.sh
        permissions: "0755"
        owner: root:root
        content: |
          #!/usr/bin/env bash
          set -euo pipefail

          ACCOUNT_NAME="$${1:-}"
          CONTAINER_NAME="$${2:-logs}"
          BLOB_NAME="$${3:-proof.txt}"
          CONTENT="$${4:-hello from managed identity (fk-spoke2-vm)}"

          if [[ -z "$${ACCOUNT_NAME}" ]]; then
            echo "usage: blob-proof.sh <storage-account-name> [container-name] [blob-name] [content]" >&2
            exit 1
          fi

          TMP_FILE="$(mktemp)"
          trap 'rm -f "$${TMP_FILE}"' EXIT

          printf '%s\n' "$${CONTENT}" > "$${TMP_FILE}"

          az login --identity --allow-no-subscriptions 1>/dev/null
          az storage container create \
            --account-name "$${ACCOUNT_NAME}" \
            --name "$${CONTAINER_NAME}" \
            --auth-mode login 1>/dev/null
          az storage blob upload \
            --account-name "$${ACCOUNT_NAME}" \
            --container-name "$${CONTAINER_NAME}" \
            --name "$${BLOB_NAME}" \
            --file "$${TMP_FILE}" \
            --auth-mode login \
            --overwrite true
    runcmd:
      - install -d -m 0755 /etc/apt/keyrings
      - curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/keyrings/microsoft.gpg >/dev/null
      - chmod go+r /etc/apt/keyrings/microsoft.gpg
      - AZ_REPO=$(lsb_release -cs)
      - echo "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $${AZ_REPO} main" > /etc/apt/sources.list.d/azure-cli.list
      - apt-get update
      - apt-get install -y azure-cli
    EOF
  )
}
