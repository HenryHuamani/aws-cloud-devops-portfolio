
# Application Load Balancer Architecture

## Laboratory

**Lab 05 – Elastic Load Balancing**

This document describes the architecture implemented during the
Application Load Balancer laboratory.

The solution distributes HTTP traffic across two Amazon EC2 instances
deployed in different Availability Zones within the same Amazon VPC.

---

## Architecture Diagram

![Application Load Balancer Architecture](architecture/lab-05-alb-architecture.png)

---

## Architecture Overview

The architecture uses an internet-facing Application Load Balancer to
receive HTTP requests from clients.

The load balancer forwards incoming requests to a Target Group containing
two Amazon EC2 instances.

Each instance runs an Apache HTTP server and is deployed in a different
public subnet and Availability Zone.

Health checks are used to ensure that traffic is forwarded only to
healthy registered targets.

---

## Main Components

| Component | Resource |
|---|---|
| Amazon VPC | `portfolio-vpc` |
| VPC CIDR | `10.0.0.0/16` |
| Application Load Balancer | `portfolio-alb` |
| Load Balancer Scheme | Internet-facing |
| Listener | HTTP – Port 80 |
| Target Group | `portfolio-web-tg` |
| Target Type | EC2 Instances |
| Health Check Protocol | HTTP |
| Health Check Path | `/` |
| Public Subnet A | `10.0.1.0/24` |
| Availability Zone A | `us-east-2a` |
| Public Subnet B | `10.0.3.0/24` |
| Availability Zone B | `us-east-2b` |
| EC2 Server 01 | `portfolio-web-server-1` |
| EC2 Server 02 | `portfolio-web-server-2` |
| Web Server | Apache HTTP Server |
| Security Group | `web-sg` |

---

## Request Flow

```text
Client
  │
  ▼
Application Load Balancer
portfolio-alb
HTTP :80
  │
  ▼
Target Group
portfolio-web-tg
  │
  ├──────────────────────┐
  ▼                      ▼
EC2 Server 01         EC2 Server 02
us-east-2a            us-east-2b
Apache HTTP           Apache HTTP