# Azure Routing with Terraform/OpenTofu – Training Examples

This directory contains all progressive examples used with the **terraform-az-fk-routing** module.
The examples are designed as **incremental building blocks**, starting from a simple Azure route table and gradually evolving toward hub-and-spoke transit routing and forced tunneling patterns.

These examples are part of the **[FoggyKitchen.com training ecosystem](https://foggykitchen.com/courses-2/)** and are used across Azure and multicloud courses covering networking, private connectivity, and architecture fundamentals.

---

## 🧭 Example Overview

| Example | Title | Key Topics |
|:-------:|:------|:-----------|
| 01 | **Basic UDR** | Route table, custom route, subnet association |
| 02 | **Hub-and-Spoke with Router VM** | Transit routing, UDR, VNet peering, router VM, NSG |
| 03 | **Forced Tunneling via Hub Router VM** | Default route `0.0.0.0/0`, NAT, centralized outbound egress |

Each example builds on the **concepts** introduced in the previous one, but can be applied independently for learning and experimentation.

---

## ⚙️ How to Use

Each example directory contains:
- Terraform/OpenTofu configuration (`.tf`)
- A focused `README.md` explaining the goal of the example
- A minimal, runnable architecture

To run an example:

```bash
cd examples/01_basic_udr
tofu init
tofu plan
tofu apply
```

You can apply examples independently, but the **recommended approach is sequential**:
01 → 02 → 03

This mirrors real-world routing design, where custom routes are introduced first, then transit routing, and finally centralized outbound egress through forced tunneling.

---

## 🧩 Design Principles

- One example = one architectural goal
- No unused or placeholder resources
- Clear separation of concerns (routing, networking, security, compute)
- Examples designed to integrate with other modules such as VNet, NSG, Peering, and Compute

These examples intentionally avoid:
- Full landing zones
- Opinionated enterprise frameworks
- Hidden dependencies between examples

---

## 🧩 Related Resources

- [FoggyKitchen Azure Routing Module (terraform-az-fk-routing)](../)
- [FoggyKitchen Azure VNet Module (terraform-az-fk-vnet)](https://github.com/mlinxfeld/terraform-az-fk-vnet)
- [FoggyKitchen Azure VNet Peering Module (terraform-az-fk-vnet-peering)](https://github.com/mlinxfeld/terraform-az-fk-vnet-peering)
- [FoggyKitchen Azure NSG Module (terraform-az-fk-nsg)](https://github.com/mlinxfeld/terraform-az-fk-nsg)
- [FoggyKitchen Azure Compute Module (terraform-az-fk-compute)](https://github.com/mlinxfeld/terraform-az-fk-compute)
- [FoggyKitchen Azure Load Balancer Module (terraform-az-fk-loadbalancer)](https://github.com/mlinxfeld/terraform-az-fk-loadbalancer)
- [FoggyKitchen Azure Bastion Module (terraform-az-fk-bastion)](https://github.com/mlinxfeld/terraform-az-fk-bastion)
- [FoggyKitchen Azure NAT Gateway Module (terraform-az-fk-natgw)](https://github.com/mlinxfeld/terraform-az-fk-natgw)
- [FoggyKitchen Azure Storage Module (terraform-az-fk-storage)](https://github.com/mlinxfeld/terraform-az-fk-storage)
- [FoggyKitchen AKS Module (terraform-az-fk-aks)](https://github.com/mlinxfeld/terraform-az-fk-aks)

---

## 🪪 License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.  
See [LICENSE](../LICENSE) for details.

---

© 2026 FoggyKitchen.com — *Cloud. Code. Clarity.*
