# Study Notes

# Lab 07 – Amazon RDS

These notes summarize the key concepts learned while integrating Amazon RDS into the NovaCommerce application.

The objective is to understand not only how to deploy Amazon RDS, but also why each architectural decision was made.

---

# What is Amazon RDS?

Amazon Relational Database Service (Amazon RDS) is a fully managed database service that simplifies the deployment, operation, maintenance, and scaling of relational databases in AWS.

Instead of installing and maintaining MySQL manually on an EC2 instance, Amazon RDS automates infrastructure management tasks such as:

- Provisioning
- Software installation
- Patch management
- Automated backups
- Monitoring
- Storage management
- High availability
- Recovery

This allows engineers to focus on application development rather than database administration.

---

# Why Amazon RDS?

For NovaCommerce, the objective was to provide a persistent database capable of storing business information independently of the application servers.

Since the web layer is deployed using Auto Scaling Groups, EC2 instances are ephemeral.

If MySQL were installed locally on each EC2 instance:

- data would be lost when instances terminate;
- application servers would become stateful;
- horizontal scaling would be difficult.

Amazon RDS solves this problem by separating compute from persistent storage.

---

# Why reuse the existing VPC?

Instead of creating a new VPC, the existing networking infrastructure from previous laboratories was reused.

Benefits include:

- Consistent architecture
- Reduced complexity
- Lower operational overhead
- Better integration between services

Infrastructure reuse is a common practice in production AWS environments.

---

# Why Private Subnets?

The database stores sensitive business information such as:

- Customers
- Orders
- Inventory
- Payments

For this reason, Amazon RDS should never be directly exposed to the Internet.

Deploying RDS inside private subnets provides:

- Network isolation
- Reduced attack surface
- Better compliance with AWS security best practices

---

# Why DB Subnet Groups?

Amazon RDS requires a DB Subnet Group to determine where database instances can be deployed.

A DB Subnet Group typically contains multiple private subnets across different Availability Zones.

Benefits include:

- High Availability support
- Multi-AZ capability
- Fault tolerance
- Managed database placement

---

# Why Security Groups instead of Public Access?

Initially, it may seem easier to allow database access from a public IP.

However, production systems should avoid exposing databases directly to the Internet.

Instead, Amazon EC2 communicates with Amazon RDS through Security Groups.

This approach follows the Principle of Least Privilege.

```
Internet
        │
        ▼
     EC2
        │
Security Group
        │
        ▼
Amazon RDS
```

---

# SSL/TLS Encryption

All communication between Amazon EC2 and Amazon RDS should be encrypted.

During this laboratory:

- Amazon RDS certificate bundle was downloaded.
- SSL connection was established.
- TLS encryption was verified.

Benefits:

- Secure authentication
- Credential protection
- Data confidentiality
- Protection against man-in-the-middle attacks

---

# Database Design

NovaCommerce uses a normalized relational database.

Main entities:

```
Clientes

↓

Pedidos

↓

Detalle Pedido

↑

Productos

↑

Categorías

Inventario

Pagos
```

Relationships are enforced through Foreign Keys.

Benefits:

- Data consistency
- Referential integrity
- Reduced duplication
- Easier reporting

---

# CRUD Operations

CRUD represents the four fundamental database operations.

## Create

Insert new records.

Example:

- Customers
- Products
- Orders

---

## Read

Retrieve information using:

- SELECT
- JOIN
- Views

---

## Update

Modify existing information.

Example:

- Inventory
- Order status

---

## Delete

Remove unnecessary records while preserving referential integrity.

---

# Why Inventory is separated?

Although the products table stores stock quantity, inventory movements should be tracked independently.

Inventory allows recording:

- Product entries
- Product exits
- Manual adjustments

This creates an audit trail for stock management.

---

# Why Payments are separated?

Orders and payments represent different business processes.

An order may exist before payment.

A payment may:

- be approved;
- remain pending;
- be rejected.

Keeping payments in a separate table follows normalization principles and improves business flexibility.

---

# Common Troubleshooting Lessons

Several practical lessons were learned during this laboratory.

## DNS

Always verify DNS resolution before assuming a networking problem.

Useful command:

```bash
getent hosts <RDS_ENDPOINT>
```

---

## Security Groups

Most connectivity issues originate from incorrect Security Group configuration.

Always verify:

- inbound rules
- outbound rules
- source Security Group

---

## SSL

Client compatibility matters.

MariaDB and MySQL clients do not always use the same SSL parameters.

---

## Endpoint

Never type AWS endpoints manually.

Always copy them directly from the AWS Console.

---

# Best Practices

During this laboratory the following AWS best practices were applied.

- Deploy databases inside private subnets.
- Disable Public Access.
- Use Security Groups.
- Encrypt database connections.
- Separate compute from persistence.
- Follow the Principle of Least Privilege.
- Normalize relational databases.
- Reuse existing infrastructure whenever possible.

---

# Key Concepts Learned

After completing this laboratory I can confidently explain:

- Amazon RDS
- DB Subnet Groups
- Private Subnets
- Security Groups
- SSL/TLS for RDS
- CRUD Operations
- Relational Database Design
- Foreign Keys
- Database Views
- Three-Tier Architecture
- Infrastructure Reuse
- AWS Database Best Practices