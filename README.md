# terraform-az-fk-routing

This repository contains a reusable **Terraform / OpenTofu module** and progressive examples for deploying **Azure routing resources** — starting from a simple User Defined Route (UDR) and evolving toward hub-and-spoke transit routing, forced tunneling, and dual-NIC NVA patterns.

It is part of the **[FoggyKitchen.com training ecosystem](https://foggykitchen.com/courses/azure-fundamentals-terraform-course/)** and is designed as a **clean, composable routing layer** that builds on top of an existing Azure networking foundation (VNets, subnets, peering, and optional router appliances).

---

## 🎯 Purpose

The goal of this module is to provide a **clear, educational, and architecture-aware reference implementation** for Azure routing:

- Focused on **Route Tables, Routes, and Subnet Associations**
- Explicit inputs and outputs, with no hidden dependencies
- Designed to integrate cleanly with:
  - Azure VNets and subnets
  - VNet peering
  - Router VMs and NVAs
  - Hub-and-spoke network topologies
  - Centralized outbound egress designs

This is **not** a full landing zone or opinionated platform module.  
It is a **learning-first, building-block module**.

---

## ✨ What the module does

Depending on configuration and example used, the module can create:

- Azure Route Tables
- One or more routes per route table
- Subnet-to-route-table associations
- Multiple route tables from a single map-based input
- Routing policies for:
  - Basic UDR scenarios
  - Transit routing through a router VM or NVA
  - Hub-and-spoke network designs
  - Forced tunneling through a centralized egress point
  - Dual-NIC NVA next-hop patterns

The module intentionally does **not** create:
- Virtual Networks or subnets
- Network Security Groups
- Virtual Machines or router appliances
- VNet peering
- Azure Firewall
- NAT Gateway

Each of those concerns belongs in its **own dedicated module**.

---

## 📂 Repository Structure

```bash
terraform-az-fk-routing/
├── examples/
│   ├── 01_basic_udr/
│   ├── 02_hub_spoke_with_routing/
│   ├── 03_forced_tunneling/
│   ├── 04_nva_dual_nic/
│   └── README.md
├── main.tf
├── inputs.tf
├── outputs.tf
├── versions.tf
├── LICENSE
└── README.md
```

---

## 🚀 Example Usage

```hcl
module "routing" {
  source = "git::https://github.com/mlinxfeld/terraform-az-fk-routing.git?ref=v0.1.0"

  resource_group_name = "fk-rg"

  route_tables = {
    rt-basic = {
      location = "westeurope"

      routes = [
        {
          name           = "default-to-internet"
          address_prefix = "0.0.0.0/0"
          next_hop_type  = "Internet"
        }
      ]

      subnet_ids = [
        module.vnet.subnet_ids["app"]
      ]
    }
  }
}
```

## Transit Routing Usage

The module can also be used in a **hub-and-spoke** design where traffic is forwarded through a router VM or NVA in the hub:

```hcl
module "routing" {
  source = "git::https://github.com/mlinxfeld/terraform-az-fk-routing.git"

  resource_group_name = "fk-rg"

  route_tables = {
    rt-spoke1 = {
      location = "westeurope"

      routes = [
        {
          name           = "to-spoke2-via-hub"
          address_prefix = "10.2.0.0/16"
          next_hop_type  = "VirtualAppliance"
          next_hop_ip    = "10.0.1.4"
        }
      ]

      subnet_ids = [
        module.vnet_spoke1.subnet_ids["fk-subnet-spoke1"]
      ]
    }
  }
}
```

For a working transit-routing design in Azure, `next_hop_ip` must point to a real forwarding device such as a router VM, NVA, or Azure Firewall.

## Forced Tunneling Usage

The module can also be used to force outbound Internet traffic from spoke subnets through a centralized router in the hub:

```hcl
module "routing" {
  source = "git::https://github.com/mlinxfeld/terraform-az-fk-routing.git"

  resource_group_name = "fk-rg"

  route_tables = {
    rt-spoke1 = {
      location = "westeurope"

      routes = [
        {
          name           = "default-to-internet-via-hub"
          address_prefix = "0.0.0.0/0"
          next_hop_type  = "VirtualAppliance"
          next_hop_ip    = "10.0.1.4"
        }
      ]

      subnet_ids = [
        module.vnet_spoke1.subnet_ids["fk-subnet-spoke1"]
      ]
    }
  }
}
```

For a working forced tunneling design in Azure, the central router must provide IP forwarding and NAT for outbound traffic.

## Dual-NIC NVA Usage

The module can also be used in a more appliance-like topology, where a router VM exposes:

- an inside NIC used as the `VirtualAppliance` next hop for spoke route tables
- an outside NIC used for outbound egress and NAT

This keeps Azure route tables simple while allowing a clearer inside/outside separation in the router VM design.

---

## ⚙️ Module Inputs

| Variable | Description |
|------|-------------|
| `resource_group_name` | Name of the Azure resource group |
| `route_tables` | Map of route tables with routes and subnet associations |
| `tags` | Optional tags applied to route tables |

### `route_tables` object schema

```hcl
route_tables = {
  rt-name = {
    location = "westeurope"

    routes = [
      {
        name           = "route-name"
        address_prefix = "10.2.0.0/16"
        next_hop_type  = "VirtualAppliance"
        next_hop_ip    = "10.0.1.4"
      }
    ]

    subnet_ids = [
      "/subscriptions/.../subnets/example"
    ]
  }
}
```

---

## 📤 Outputs

| Output | Description |
|------|-------------|
| `route_table_ids` | Map of route table IDs |
| `route_table_names` | Map of route table names |

---

## 🧠 Design Philosophy

- Routing is a **dedicated concern**, separate from networking, security, and compute
- Route tables should be explicit and easy to reason about
- Transit routing is only useful when paired with a real forwarding device
- Forced tunneling is only useful when paired with a real egress device that can perform NAT
- Dual-NIC NVA topologies can better model real appliances than single-NIC router labs
- Outputs are first-class citizens for composition with other modules

---

## 🧩 Related Modules & Training

- [terraform-az-fk-vnet](https://github.com/mlinxfeld/terraform-az-fk-vnet)
- [terraform-az-fk-vnet-peering](https://github.com/mlinxfeld/terraform-az-fk-vnet-peering)
- [terraform-az-fk-nsg](https://github.com/mlinxfeld/terraform-az-fk-nsg)
- [terraform-az-fk-compute](https://github.com/mlinxfeld/terraform-az-fk-compute)
- [terraform-az-fk-loadbalancer](https://github.com/mlinxfeld/terraform-az-fk-loadbalancer)
- [terraform-az-fk-bastion](https://github.com/mlinxfeld/terraform-az-fk-bastion)
- [terraform-az-fk-natgw](https://github.com/mlinxfeld/terraform-az-fk-natgw)
- [terraform-az-fk-storage](https://github.com/mlinxfeld/terraform-az-fk-storage)
- [terraform-az-fk-aks](https://github.com/mlinxfeld/terraform-az-fk-aks)

---

## 🪪 License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.  
See [LICENSE](LICENSE) for details.

---

© 2026 FoggyKitchen.com — *Cloud. Code. Clarity.*
