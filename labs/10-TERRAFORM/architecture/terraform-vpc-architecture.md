# AWS VPC Architecture — Terraform

## Architecture Overview

This architecture represents the AWS network infrastructure deployed and managed through Terraform in Lab 10.

The environment is deployed in the **AWS us-east-2 (Ohio) Region** and uses a custom VPC distributed across two Availability Zones.

## Architecture

```text
                              Internet
                                  │
                                  │
                         Internet Gateway
                                  │
                           0.0.0.0/0 Route
                                  │
                     ┌─────────────────────────┐
                     │   Public Route Table    │
                     └────────────┬────────────┘
                                  │
             ┌────────────────────┴────────────────────┐
             │                                         │
             │        VPC: 10.20.0.0/16               │
             │                                         │
             │  ┌────────────────┐ ┌────────────────┐  │
             │  │   us-east-2a   │ │   us-east-2b   │  │
             │  │                │ │                │  │
             │  │ Public Subnet  │ │ Public Subnet  │  │
             │  │ 10.20.1.0/24   │ │ 10.20.2.0/24   │  │
             │  │                │ │                │  │
             │  │ Private Subnet │ │ Private Subnet │  │
             │  │ 10.20.11.0/24  │ │ 10.20.12.0/24  │  │
             │  └────────────────┘ └────────────────┘  │
             │                                         │
             │         Private Route Table             │
             │        ┌───────────────────┐            │
             │        │ Local VPC routing │            │
             │        └───────────────────┘            │
             │                                         │
             └─────────────────────────────────────────┘
```

## Network Design

| Component | Configuration |
|---|---|
| AWS Region | us-east-2 |
| VPC CIDR | 10.20.0.0/16 |
| Availability Zones | us-east-2a, us-east-2b |
| Public Subnet 1 | 10.20.1.0/24 |
| Public Subnet 2 | 10.20.2.0/24 |
| Private Subnet 1 | 10.20.11.0/24 |
| Private Subnet 2 | 10.20.12.0/24 |
| Internet Gateway | Attached to VPC |
| Public Route | 0.0.0.0/0 → Internet Gateway |
| Public Route Table | Associated with both public subnets |
| Private Route Table | Associated with both private subnets |
| Infrastructure Management | Terraform |

## Routing Model

### Public Subnets

The two public subnets are associated with the public route table.

The public route table contains:

```text
10.20.0.0/16 → local
0.0.0.0/0    → Internet Gateway
```

This provides an Internet routing path for resources deployed in the public network tier.

### Private Subnets

The two private subnets are associated with the private route table.

The current laboratory intentionally does **not** deploy a NAT Gateway.

Therefore, workloads deployed in the private subnets do not have direct outbound Internet connectivity through this architecture.

This design keeps the laboratory focused on understanding:

- VPC segmentation
- public and private subnet architecture
- route table associations
- Internet Gateway routing
- Terraform modularization
- Infrastructure as Code lifecycle

## Infrastructure as Code

The network architecture is implemented using a reusable Terraform VPC module:

```text
terraform/
├── environments/
│   └── dev/
│       ├── main.tf
│       ├── providers.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars.example
│
└── modules/
    └── vpc/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

This separation allows infrastructure components to be reused across multiple environments while environment-specific configuration remains isolated.

## Validation

The deployed infrastructure was validated using:

- Terraform state inspection
- Terraform outputs
- Terraform idempotency validation
- AWS CLI VPC discovery
- AWS CLI subnet validation
- Route table validation
- Public subnet association validation
- Private subnet association validation
- Internet Gateway route validation

Supporting screenshots are available in the [`evidence`](../evidence/) directory.

## Current Architecture Scope

This laboratory deploys the networking foundation only.

The following components are intentionally outside the current scope:

- NAT Gateway
- EC2 workloads
- Application Load Balancer
- Auto Scaling Groups
- RDS
- ECS / EKS
- Route 53
- CloudFront

These components can be integrated in subsequent infrastructure laboratories.

---

> This architecture demonstrates a reproducible multi-AZ AWS network foundation provisioned through Terraform Infrastructure as Code.