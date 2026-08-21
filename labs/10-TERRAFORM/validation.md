# Terraform Infrastructure Validation

This document contains the technical validation performed after deploying
the Terraform-managed AWS networking infrastructure.

## Validation Environment

| Component | Value |
|---|---|
| AWS Region | us-east-2 |
| Environment | dev |
| Infrastructure as Code | Terraform |
| Cloud Provider | AWS |
| VPC CIDR | 10.20.0.0/16 |
| Availability Zones | us-east-2a, us-east-2b |
| Public Subnets | 2 |
| Private Subnets | 2 |

---

## 1. VPC Validation

The VPC was validated using the AWS CLI after the Terraform deployment.

The validation confirmed:

- VPC successfully created.
- CIDR block configured as `10.20.0.0/16`.
- VPC state is `available`.
- Resource tags were successfully applied.

---

## 2. Subnet Validation

The deployed subnet architecture was validated using AWS CLI.

The environment contains:

| Subnet Type | Availability Zone | CIDR |
|---|---|---|
| Public | us-east-2a | 10.20.1.0/24 |
| Private | us-east-2a | 10.20.11.0/24 |
| Private | us-east-2b | 10.20.12.0/24 |
| Public | us-east-2b | 10.20.2.0/24 |

Public subnets have automatic public IP assignment enabled.

Private subnets do not automatically assign public IP addresses.

This validates the intended public/private network segmentation.

---

## 3. Route Table Validation

Two dedicated route tables were validated:

- Public Route Table
- Private Route Table

The public subnets are explicitly associated with the public route table.

The private subnets are explicitly associated with the private route table.

---

## 4. Internet Connectivity Validation

The public route table contains the following routes:

| Destination | Target | State |
|---|---|---|
| 10.20.0.0/16 | local | active |
| 0.0.0.0/0 | Internet Gateway | active |

The `0.0.0.0/0` route confirms that resources deployed in the public
network tier can route Internet-bound traffic through the Internet Gateway,
subject to security controls and resource configuration.

---

## 5. Terraform State Validation

Terraform successfully tracks the deployed infrastructure.

The following workflow was validated:

```text
terraform init
        ↓
terraform fmt
        ↓
terraform validate
        ↓
terraform plan
        ↓
terraform apply
        ↓
terraform output
        ↓
terraform plan
        ↓
No changes