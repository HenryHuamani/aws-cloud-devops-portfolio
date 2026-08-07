# Architecture Decisions

# Lab 07 – Amazon RDS

This document explains the architectural decisions made during the implementation of Amazon RDS for the NovaCommerce application.

The objective is not only to describe what was implemented, but also to justify why each design decision was selected.

---

# Decision 1 – Use Amazon RDS instead of MySQL on Amazon EC2

## Context

NovaCommerce required a relational database capable of storing persistent business information independently of the application servers.

The application layer had already been deployed using Amazon EC2 instances managed by an Auto Scaling Group.

## Decision

Use Amazon RDS MySQL instead of installing MySQL manually on Amazon EC2.

## Rationale

Amazon RDS significantly reduces operational overhead by automating:

- Database provisioning
- Software installation
- Patch management
- Automated backups
- Monitoring
- Maintenance
- Storage management
- Recovery

Using Amazon RDS also aligns with AWS Well-Architected Framework recommendations by allowing engineers to focus on application development instead of database administration.

## Trade-offs

Advantages

- Managed service
- Automated backups
- Lower operational effort
- Better reliability
- Easier scaling

Disadvantages

- Less operating system control
- Slightly higher cost than self-managed databases
- Some administrative operations are restricted

---

# Decision 2 – Reuse Existing Infrastructure

## Context

Previous laboratories already implemented:

- Amazon VPC
- Public Subnets
- Private Subnets
- Internet Gateway
- Route Tables
- Security Groups
- Amazon EC2
- Auto Scaling Group

## Decision

Reuse the existing infrastructure instead of deploying a new environment.

## Rationale

Infrastructure reuse better represents production cloud environments.

Benefits include:

- Lower deployment complexity
- Easier management
- Reduced cost
- Consistent architecture
- Better integration between services

This approach also demonstrates how cloud environments evolve incrementally rather than being rebuilt for each new component.

---

# Decision 3 – Deploy Amazon RDS in Private Subnets

## Context

The database stores business-critical information.

Examples include:

- Customers
- Orders
- Inventory
- Payments

## Decision

Deploy Amazon RDS inside private subnets.

## Rationale

Private subnets prevent direct Internet access to the database.

Application servers communicate with Amazon RDS through private networking inside the VPC.

Benefits

- Reduced attack surface
- Improved security
- Better compliance with AWS best practices
- Separation of application and database layers

---

# Decision 4 – Disable Public Access

## Context

Amazon RDS allows databases to receive public IP addresses.

## Decision

Configure:

```
Public Access = No
```

## Rationale

Production databases should not be directly accessible from the Internet.

Access should always occur through trusted application servers.

This architecture minimizes unnecessary exposure.

---

# Decision 5 – Use Dedicated Security Groups

## Context

The application server requires database access.

## Decision

Create a dedicated Security Group for Amazon RDS.

Allow inbound MySQL traffic only from the Security Group assigned to the application servers.

## Rationale

Using Security Group references instead of public IP addresses provides:

- Better scalability
- Easier maintenance
- Dynamic authorization
- Improved security

This follows the AWS Principle of Least Privilege.

---

# Decision 6 – Secure Database Connections with SSL/TLS

## Context

Database traffic contains sensitive business information.

## Decision

Enable encrypted communication between Amazon EC2 and Amazon RDS.

## Rationale

SSL/TLS protects:

- Credentials
- Customer information
- Business transactions
- Database queries

Encryption also prevents man-in-the-middle attacks.

---

# Decision 7 – Design a Normalized Relational Database

## Context

NovaCommerce stores multiple business entities.

## Decision

Normalize the relational database.

The following entities were created:

- clientes
- categorias
- productos
- inventario
- pedidos
- detalle_pedido
- pagos

## Rationale

Normalization reduces:

- Data duplication
- Inconsistency
- Update anomalies

It also improves reporting and data integrity.

---

# Decision 8 – Separate Inventory from Products

## Context

Products maintain current stock.

Inventory records stock movements.

## Decision

Create an independent inventory table.

## Rationale

Inventory movements provide historical traceability.

Benefits include:

- Auditability
- Better reporting
- Operational visibility
- Future warehouse integration

---

# Decision 9 – Separate Payments from Orders

## Context

Orders and payments have different business lifecycles.

## Decision

Implement an independent payments table.

## Rationale

A payment may be:

- Pending
- Processed
- Rejected

Separating payments improves flexibility and follows database normalization principles.

---

# Decision 10 – Validate Through Business Workflows

## Context

Simply creating tables does not demonstrate that the system works.

## Decision

Validate the implementation using realistic business operations.

Validation included:

- Customer registration
- Product creation
- Inventory management
- Order creation
- Payment processing
- CRUD operations
- JOIN queries
- Views

## Rationale

Business-oriented validation demonstrates that the relational model supports real application scenarios rather than isolated SQL examples.

---

# Architecture Evolution

Previous laboratories provided the networking and compute layers.

```
Internet

↓

Application

↓

Amazon EC2
```

This laboratory introduced the persistence layer.

```
Internet

↓

Application Load (Future)

↓

Amazon EC2

↓

Amazon RDS

↓

NovaCommerce Database
```

The resulting architecture is now prepared for future laboratories involving:

- Application Load Balancer
- CloudWatch
- Docker
- Amazon ECS
- CI/CD
- Kubernetes

---

# Final Design Principles

The implementation followed several AWS architectural principles.

- Infrastructure reuse
- Separation of concerns
- Least Privilege
- Private networking
- Managed services
- Secure communications
- Relational normalization
- Production-oriented design
- Scalability
- Maintainability

These principles provide a secure and extensible foundation for the remaining laboratories in the AWS Cloud & DevOps Portfolio.