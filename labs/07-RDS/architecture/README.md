# Architecture

# Lab 07 – Amazon RDS

This document describes the architecture implemented during Lab 07, where Amazon RDS was integrated into the existing AWS infrastructure to provide a secure and persistent relational database for the NovaCommerce application.

---

# Overview

The objective of this laboratory was to introduce the persistence layer into the existing cloud architecture without rebuilding the networking infrastructure.

The solution reuses the Amazon VPC, public and private subnets, Security Groups, and Auto Scaling Group created in previous laboratories.

Amazon RDS was deployed inside private subnets to provide a secure, highly available, and managed relational database service for the NovaCommerce application.

---

# Architecture Diagram

The following diagram illustrates the final architecture implemented in this laboratory.

![Lab 07 Architecture](../architecture/lab-07-rds-architecture.png)

---

# Architecture Components

| Component | Purpose |
|----------|---------|
| Amazon VPC | Provides network isolation for all AWS resources. |
| Public Subnets | Host the EC2 instances that serve the web application. |
| Private Subnets | Host the Amazon RDS database instance. |
| Internet Gateway | Enables Internet connectivity for public resources. |
| Route Tables | Control network routing between subnets and the Internet. |
| Security Groups | Control communication between EC2 and Amazon RDS. |
| Auto Scaling Group | Automatically manages EC2 capacity. |
| Amazon EC2 | Hosts the NovaCommerce web application. |
| Amazon RDS MySQL | Provides persistent relational database services. |

---

# Network Design

The network follows a multi-tier architecture.

```
Internet
      │
Internet Gateway
      │
Public Subnets
      │
Amazon EC2
      │
Security Group (web-sg)
      │
TCP 3306
      │
Security Group (portfolio-rds-sg)
      │
Private Subnets
      │
Amazon RDS MySQL
```

The database remains isolated inside the private tier and is never directly exposed to the Internet.

---

# Request Flow

A typical application request follows this sequence.

1. A client accesses the web application hosted on Amazon EC2.
2. The application processes the request.
3. The application establishes a secure connection to Amazon RDS.
4. SQL queries are executed.
5. Amazon RDS returns the requested information.
6. The application sends the response back to the client.

---

# Security Design

Several security controls were implemented.

- Amazon RDS deployed in private subnets.
- Public access disabled.
- Security Groups following the Principle of Least Privilege.
- Database communication restricted to EC2 instances.
- SSL/TLS encryption between EC2 and Amazon RDS.
- Managed database service with automated backups.

---

# Database Layer

The persistence layer was implemented using the NovaCommerce database.

Main entities include:

- clientes
- categorias
- productos
- inventario
- pedidos
- detalle_pedido
- pagos

Foreign Keys enforce referential integrity across the relational model.

---

# Scalability

The application layer can scale horizontally through the existing Auto Scaling Group.

Because Amazon RDS provides persistent storage independently of EC2 instances, application servers remain stateless and can be replaced without affecting business data.

---

# Architecture Evolution

This laboratory extends the architecture created in previous labs.

Lab 05

```
VPC
│
└── EC2
```

Lab 06

```
VPC
│
├── Auto Scaling Group
└── EC2
```

Lab 07

```
VPC
│
├── Auto Scaling Group
├── EC2
└── Amazon RDS
```

This architecture provides the persistence layer required for future laboratories involving Load Balancing, Monitoring, Containers, and CI/CD.