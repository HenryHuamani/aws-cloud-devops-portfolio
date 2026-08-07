# ☁️ Amazon RDS

## Lab 07 — Relational Database Service

> Build a secure, scalable, and cost-effective managed relational database using Amazon RDS within a private Amazon VPC as part of the NovaCommerce cloud migration journey.

---

## Lab Information

| Property | Value |
|----------|-------|
| **Lab** | 07 |
| **Service** | Amazon RDS |
| **Category** | Database |
| **Difficulty** | Intermediate |
| **Estimated Time** | 60–90 minutes |
| **Status** | 🚧 In Progress |
| **Project** | NovaCommerce Cloud Migration |

---

## Technologies

![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)
![Amazon RDS](https://img.shields.io/badge/Amazon_RDS-527FFF?style=for-the-badge&logo=amazonrds&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Amazon EC2](https://img.shields.io/badge/Amazon_EC2-FF9900?style=for-the-badge&logo=amazonec2&logoColor=white)
![Amazon VPC](https://img.shields.io/badge/Amazon_VPC-8C4FFF?style=for-the-badge)
![Amazon CloudWatch](https://img.shields.io/badge/Amazon_CloudWatch-FF4F8B?style=for-the-badge)

---

## Table of Contents

- [Overview](#overview)
- [Why This Lab Matters](#why-this-lab-matters)
- [Business Scenario](#business-scenario)
- [Problem Statement](#problem-statement)
- [Solution Overview](#solution-overview)
- [Learning Objectives](#learning-objectives)
- [AWS Services Used](#aws-services-used)
- [Prerequisites](#prerequisites)
- [Architecture](#architecture)
  - [Architecture Diagram](#architecture-diagram)
  - [Components](#components)
  - [Network Flow](#network-flow)
  - [Architecture Principles](#architecture-principles)
- [Design Decisions](#design-decisions)
- [Alternatives Considered](#alternatives-considered)
- [Implementation](#implementation)
- [Validation](#validation)
  - [Acceptance Criteria](#acceptance-criteria)
  - [Validation Evidence](#validation-evidence)
- [Security Considerations](#security-considerations)
- [Cost Optimization](#cost-optimization)
- [Best Practices](#best-practices)
- [Cleanup](#cleanup)
- [Key Takeaways](#key-takeaways)
- [Skills Demonstrated](#skills-demonstrated)
- [Troubleshooting](#troubleshooting)
- [References](#references)

---

## Overview

Amazon Relational Database Service (Amazon RDS) is a fully managed relational database service provided by AWS that simplifies the deployment, operation, and scaling of databases in the cloud. It eliminates many of the administrative tasks associated with traditional database management, including software installation, patching, backups, monitoring, and infrastructure maintenance.

In this lab, an Amazon RDS MySQL instance will be deployed inside a secure Amazon Virtual Private Cloud (VPC). The implementation focuses on networking, security, storage configuration, automated backups, monitoring, and database connectivity while following AWS best practices.

This laboratory extends the cloud infrastructure built in previous labs by adding the persistence layer required for modern three-tier applications.

---

## Why This Lab Matters

Modern cloud applications require persistent storage that remains available even when application servers are replaced or scaled automatically. This lab demonstrates how Amazon RDS provides a secure, managed, and highly reliable relational database solution that enables scalable application architectures while reducing operational complexity.

---

## Business Scenario

NovaCommerce is a rapidly growing e-commerce company undergoing a cloud migration to modernize its application architecture using AWS managed services.

In previous laboratories, the web application infrastructure was built on Amazon EC2 within a custom Amazon VPC and later enhanced with Auto Scaling Groups to improve scalability and availability. While the compute layer can now scale dynamically, the application still requires a persistent relational database capable of storing business-critical information independently of the application servers.

To address this requirement, Amazon RDS for MySQL is introduced as the managed database platform for NovaCommerce.

During this lab, a secure Amazon RDS instance is deployed inside private subnets of the existing VPC. Database connectivity is restricted through Security Groups, ensuring that only authorized EC2 instances can communicate with the database.

A relational database named **novacommerce** is implemented to support the core business entities of the application, including:

- Customers
- Categories
- Products
- Inventory
- Orders
- Order Details
- Payments

The database is validated by performing complete CRUD operations, relational queries, inventory updates, payment registration, and secure SSL/TLS connectivity from the application server.

This implementation establishes the persistence layer required for the remaining laboratories in the portfolio, where the NovaCommerce application will continue evolving through Load Balancing, Monitoring, Containers, CI/CD pipelines, and Kubernetes deployments.

---

## Problem Statement

Application servers are designed to process requests rather than permanently store business information. In an Auto Scaling environment, EC2 instances can be terminated and replaced automatically, causing any locally stored data to be lost.

Managing a database directly on virtual machines also introduces operational challenges such as operating system maintenance, software updates, backups, monitoring, and disaster recovery.

The organization requires a managed database solution that provides persistent storage, simplifies administration, improves security, and reduces operational overhead.

---

## Solution Overview

To provide a secure and persistent data layer for NovaCommerce, Amazon RDS MySQL was integrated into the existing AWS infrastructure built in previous laboratories.

Instead of installing and maintaining MySQL on Amazon EC2 instances, a fully managed Amazon RDS database was deployed inside private subnets within the existing Amazon VPC.

A dedicated DB Subnet Group and a Security Group were created to ensure that database access is restricted exclusively to authorized EC2 instances belonging to the application layer.

After the database deployment, the application server successfully established a secure SSL/TLS connection to Amazon RDS using the MySQL client.

A complete relational schema named **novacommerce** was implemented, including tables for customers, categories, products, inventory, orders, order details, and payments.

The implementation was validated by executing complete CRUD operations, relational JOIN queries, inventory transactions, payment processing, and connectivity verification through encrypted database sessions.

This architecture provides a secure, scalable, and production-oriented persistence layer that will be reused throughout the remaining laboratories of the AWS Cloud & DevOps Portfolio.

---

## Learning Objectives

By the end of this lab, you will be able to:

- Understand the role of Amazon RDS within a multi-tier application architecture.
- Deploy an Amazon RDS instance using MySQL as the database engine.
- Configure storage, authentication, and core database settings.
- Create a DB Subnet Group to deploy the database within an Amazon VPC.
- Configure Security Groups to restrict database access to authorized application servers only.
- Connect to the database from an Amazon EC2 instance.
- Validate database functionality through basic SQL operations.
- Understand automated backups, monitoring, and maintenance features provided by AWS.
- Apply AWS security and cost optimization best practices for managed relational databases.

## AWS Services Used

| AWS Service | Purpose in this Lab |
|--------------|---------------------|
| Amazon RDS | Hosts the managed MySQL relational database instance. |
| Amazon VPC | Provides secure network isolation for the database. |
| Amazon EC2 | Simulates the application server connecting to the database. |
| Security Groups | Restrict inbound and outbound traffic to authorized resources. |
| DB Subnet Group | Defines the subnets where the RDS instance is deployed. |
| Amazon CloudWatch | Collects database performance metrics and monitoring data. |
| AWS IAM | Controls permissions required to manage Amazon RDS resources. |

## Prerequisites

Before starting this lab, you should have a basic understanding of:

- Core AWS services
- Amazon EC2
- Amazon VPC
- Public and private subnets
- Security Groups
- Basic networking concepts (IP addressing, ports, and protocols)
- Basic Linux commands
- Relational databases and SQL fundamentals

It is also recommended to complete the following labs beforehand:

- Lab 02 - Amazon EC2
- Lab 04 - Amazon VPC
- Lab 05 - Application Load Balancer
- Lab 06 - Auto Scaling Groups

---

## Architecture

### Architecture Diagram

![NovaCommerce Amazon RDS Architecture](architecture/lab-07-rds-architecture.png)

### Components

#### Internet

Represents end users accessing the web application from anywhere.

#### Application Load Balancer

Distributes incoming HTTP/HTTPS requests across application servers, improving availability and scalability.

#### Amazon EC2

Hosts the web application and processes client requests.

#### Amazon VPC

Provides network isolation for all application resources.

The database remains inaccessible from the public Internet.

#### Security Groups

Act as virtual firewalls controlling inbound and outbound traffic between AWS resources.

#### Amazon RDS

Stores persistent business data such as customers, products, orders, and transactions.

### Network Flow

1. A client sends an HTTP/HTTPS request to the application.

2. The Application Load Balancer forwards the request to an available Amazon EC2 instance.

3. The application running on EC2 processes the request.

4. Whenever persistent data is required, the application establishes a private connection to Amazon RDS.

5. Security Groups ensure that only authorized application servers can access the database.

6. Amazon RDS processes the SQL operation and returns the requested data.

7. The application generates the response and sends it back to the client through the Application Load Balancer.

### Architecture Principles

| Principle              | Implementation                                                   |
| ---------------------- | ---------------------------------------------------------------- |
| Security               | Database deployed in private subnets.                            |
| High Availability      | Application designed to support Auto Scaling and Load Balancing. |
| Scalability            | Compute layer can scale independently from the database.         |
| Separation of Concerns | Application and database are deployed in separate tiers.         |
| Least Privilege        | Access to RDS is restricted through Security Groups and IAM.     |


---

## Design Decisions

The following design decisions were made based on the business scenario, AWS best practices, and the balance between functionality, security, and cost for a learning environment.

### Why Amazon RDS?

Amazon RDS was selected because it removes the operational burden of managing relational databases. Administrative tasks such as software installation, patching, backups, monitoring, and operating system maintenance are handled automatically by AWS, allowing engineers to focus on application development and database management.

### Why MySQL?

MySQL was chosen because it is one of the most widely adopted relational database engines in the industry. Its maturity, extensive community support, compatibility with many applications, and comprehensive documentation make it an excellent choice for learning and production workloads alike.

### Why Single-AZ?

A Single-AZ deployment was selected to keep the infrastructure simple and cost-effective while learning the core features of Amazon RDS. In production environments where high availability is required, a Multi-AZ deployment would be the recommended option.

### Why db.t3.micro?

The db.t3.micro instance class provides sufficient compute resources for development and laboratory environments while minimizing operational costs.

### Why gp3 Storage?

General Purpose SSD (gp3) storage was selected because it provides an excellent balance between performance and cost. It also allows storage capacity and performance to be managed more efficiently than previous SSD generations.

### Why Private Subnets?

The database is deployed inside private subnets to prevent direct Internet access. This architecture significantly improves security by ensuring that database connections are only established from trusted resources within the VPC.

### Why Security Groups?

Security Groups act as virtual firewalls that control database access. Only authorized Amazon EC2 instances are allowed to establish MySQL connections, following the Principle of Least Privilege.

## Alternatives Considered

| Alternative               | Why it was not selected                                                                                          |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| Amazon Aurora             | More powerful, but unnecessary for this learning scenario and typically more expensive.                          |
| PostgreSQL                | Excellent option, but MySQL was chosen due to its broader adoption and familiarity.                              |
| Self-managed MySQL on EC2 | Requires manual installation, backups, patching, monitoring, and maintenance, increasing operational complexity. |


---

## Implementation

The implementation of Amazon RDS for NovaCommerce followed a structured deployment approach that progressively integrated the managed database service into the cloud infrastructure created in previous laboratories.

Instead of creating an isolated database environment, this lab reused the existing Amazon VPC, networking components, and Auto Scaling infrastructure to simulate a production-oriented three-tier application architecture.

The implementation was completed in seven phases.

---

### Phase 1 – Database Network Preparation

Before deploying Amazon RDS, the networking layer was prepared to host the managed database securely.

The following resources were configured:

- DB Subnet Group using two private subnets located in different Availability Zones.
- Amazon VPC created in previous laboratories.
- Existing private networking infrastructure.
- Routing validation.

At the end of this phase, Amazon RDS had a secure network location inside the private tier of the VPC.

**Evidence**

- 01-db-subnet-group.png

---

### Phase 2 – Security Configuration

A dedicated Security Group was created specifically for the database.

Instead of allowing access from public IP addresses, inbound MySQL traffic (TCP 3306) was restricted exclusively to the Security Group assigned to the Amazon EC2 application servers.

This implementation follows the AWS Principle of Least Privilege by allowing only trusted application instances to establish database connections.

**Configuration**

| Rule | Value |
|------|-------|
| Protocol | TCP |
| Port | 3306 |
| Source | web-sg |

**Evidence**

- 02-rds-security-group.png

---

### Phase 3 – Amazon RDS Deployment

The Amazon RDS MySQL instance was deployed using the previously created networking components.

The following configuration was selected:

| Property | Value |
|----------|-------|
| Engine | MySQL Community Edition |
| Deployment | Single-AZ |
| Instance Class | db.t4g.micro |
| Storage | gp3 |
| Public Access | Disabled |
| DB Subnet Group | portfolio-db-subnet-group |
| Security Group | portfolio-rds-sg |

The database was deployed inside private subnets without a public IP address, ensuring that it could only be accessed from authorized resources within the VPC.

**Evidence**

- 03-rds-instance-creating.png
- 04-rds-instance-available.png

---

### Phase 4 – Secure Database Connectivity

After the database became available, a secure connection was established from an Amazon EC2 instance.

The MariaDB client was installed on the application server and configured to connect to Amazon RDS using SSL/TLS encryption.

The connection was validated using the Amazon RDS certificate bundle and server identity verification.

During this phase, database connectivity, endpoint resolution, and encrypted communication were successfully verified.

**Evidence**

- 05-ec2-ssh-connection.png
- 06-rds-mysql-ssl-connection.png

---

### Phase 5 – NovaCommerce Database Design

A relational database named **novacommerce** was implemented to represent the persistence layer of the e-commerce application.

The following entities were created:

- clientes
- categorias
- productos
- inventario
- pedidos
- detalle_pedido
- pagos

Foreign Key constraints were configured to enforce referential integrity between related entities.

This relational model provides the foundation for future application development in subsequent laboratories.

**Evidence**

- 07-novacommerce-schema.png

---

### Phase 6 – CRUD Validation

The database schema was validated through complete CRUD operations.

The validation included:

- Creating sample business data.
- Reading information using SQL queries.
- Updating orders and inventory.
- Deleting test records.
- Executing JOIN queries across multiple tables.
- Registering inventory movements.
- Recording customer payments.

These operations confirmed that the relational model behaves as expected and supports common e-commerce workflows.

**Evidence**

- 08-crud-operations.png
- 09-sales-view.png

### Reproducible Database Deployment

To improve reproducibility and make the laboratory easier to recreate, the NovaCommerce database definition was stored as version-controlled SQL files inside the repository.

The database resources are organized as follows:

```text
database/
├── novacommerce-schema.sql
├── sample-data.sql
└── views.sql
```

Each file has a specific responsibility:

| File | Purpose |
|------|---------|
| `novacommerce-schema.sql` | Creates the NovaCommerce database, tables, constraints, Primary Keys, and Foreign Keys. |
| `sample-data.sql` | Inserts sample customers, categories, products, orders, inventory movements, and payments. |
| `views.sql` | Creates reusable reporting views such as `vista_ventas`. |

This separation allows the database to be recreated consistently without executing SQL statements manually.

The secure RDS connection process is also automated through:

```text
scripts/connect-rds.sh
```

The script:

- Installs the MariaDB client if required.
- Downloads the official Amazon RDS CA bundle.
- Validates DNS resolution.
- Tests TCP connectivity to port 3306.
- Establishes an SSL/TLS encrypted connection to Amazon RDS.

This approach improves repeatability, maintainability, and operational consistency.

---

## Repository Structure

The Lab 07 repository is organized to separate documentation, architecture, evidence, automation, and database artifacts.

```text
07-RDS/
│
├── README.md
├── CHANGELOG.md
├── commands.md
├── interview-questions.md
├── resources.md
├── study-notes.md
├── troubleshooting.md
│
├── architecture/
│   ├── README.md
│   ├── architecture-decisions.md
│   └── lab-07-rds-architecture.png
│
├── database/
│   ├── novacommerce-schema.sql
│   ├── sample-data.sql
│   └── views.sql
│
├── diagrams/
│   └── lab-07-rds-architecture.drawio
│
├── evidence/
│   ├── 01-db-subnet-group.png
│   ├── 02-rds-security-group.png
│   ├── 03-rds-instance-creating.png
│   ├── 04-rds-instance-available.png
│   ├── 05-ec2-ssh-connection.png
│   ├── 06-rds-mysql-ssl-connection.png
│   ├── 07-novacommerce-schema.png
│   ├── 08-crud-operations.png
│   ├── 09-sales-view.png
│   └── 10-final-validation.png
│
└── scripts/
    └── connect-rds.sh
```

The structure was designed to keep the laboratory modular and easy to navigate:

- `architecture/` contains architecture documentation and exported diagrams.
- `database/` contains reproducible SQL assets.
- `diagrams/` contains editable Draw.io source files.
- `evidence/` contains implementation screenshots.
- `scripts/` contains automation utilities.

---

### Phase 7 – Final Validation

The laboratory concluded with a complete functional validation of the deployed solution.

The following checks were performed:

- Amazon RDS status verification.
- Database availability.
- SSL/TLS connection validation.
- Security Group verification.
- Database schema verification.
- CRUD verification.
- Relational query validation.
- Inventory validation.
- Payment validation.

Successful completion of these activities confirmed that Amazon RDS was fully integrated into the NovaCommerce cloud architecture and ready to support the remaining laboratories of this portfolio.

**Evidence**

- 10-final-validation.png

---

## Validation

The deployed Amazon RDS environment was validated through a series of functional, networking, security, and database tests to ensure that the persistence layer of the NovaCommerce application operates correctly.

Validation activities covered infrastructure availability, secure connectivity, relational database functionality, referential integrity, CRUD operations, and business workflow simulation.

---

### Acceptance Criteria

| Acceptance Criteria | Status |
|---------------------|:------:|
| Amazon RDS instance deployed successfully | ✅ |
| Database status is **Available** | ✅ |
| Database deployed inside private subnets | ✅ |
| Public access disabled | ✅ |
| DB Subnet Group configured correctly | ✅ |
| Security Group allows only authorized EC2 instances | ✅ |
| SSL/TLS encrypted connection established | ✅ |
| EC2 successfully connected to Amazon RDS | ✅ |
| NovaCommerce database created | ✅ |
| Relational schema successfully implemented | ✅ |
| Foreign Key relationships validated | ✅ |
| CRUD operations completed successfully | ✅ |
| Inventory transactions validated | ✅ |
| Payment registration validated | ✅ |
| JOIN queries executed successfully | ✅ |
| Sales view generated successfully | ✅ |

---

### Functional Validation

The NovaCommerce relational database was validated by simulating common business operations performed by an e-commerce application.

The following entities were successfully created and tested:

- Customers
- Categories
- Products
- Inventory
- Orders
- Order Details
- Payments

Relationships between entities were verified using Foreign Keys, ensuring referential integrity throughout the database.

---

### CRUD Validation

Complete CRUD operations were executed against the NovaCommerce database.

| Operation | Validation |
|-----------|------------|
| CREATE | New customers, products, orders, inventory movements, and payments were inserted successfully. |
| READ | Information was retrieved using SELECT statements, JOIN queries, and database views. |
| UPDATE | Product inventory and order status were updated successfully. |
| DELETE | Test records were removed without affecting referential integrity. |

---

### Connectivity Validation

The application server successfully established a secure encrypted connection to Amazon RDS using SSL/TLS.

The following validations were completed:

- Database endpoint resolution.
- Network connectivity over TCP port 3306.
- SSL certificate validation.
- Secure authentication.
- Successful SQL execution.

---

### Relational Validation

The relational model was validated by executing JOIN queries across multiple tables.

Relationships verified include:

- Customers → Orders
- Orders → Order Details
- Products → Categories
- Products → Inventory
- Orders → Payments

A consolidated sales view was also created to demonstrate how business reports can be generated from multiple related entities.

---

### Validation Evidence

| Evidence | Description |
|----------|-------------|
| 01-db-subnet-group.png | DB Subnet Group created successfully |
| 02-rds-security-group.png | Security Group configured for Amazon RDS |
| 03-rds-instance-creating.png | Amazon RDS deployment in progress |
| 04-rds-instance-available.png | Amazon RDS available |
| 05-ec2-ssh-connection.png | SSH connection established to EC2 |
| 06-rds-mysql-ssl-connection.png | Secure SSL/TLS connection to Amazon RDS |
| 07-novacommerce-schema.png | NovaCommerce database schema created |
| 08-crud-operations.png | CRUD operations executed successfully |
| 09-sales-view.png | Sales reporting view validated |
| 10-final-validation.png | Final validation of the complete solution |ok

---

## Security Considerations

Security was a primary design principle throughout the implementation of the NovaCommerce persistence layer.

Rather than exposing the database to the public Internet, Amazon RDS was integrated into the existing Amazon VPC using a layered security model based on network isolation, Security Groups, encrypted communications, and the Principle of Least Privilege.

The following security controls were implemented.

---

### Private Network Isolation

The Amazon RDS instance was deployed inside private subnets within the existing Amazon VPC.

Because the database does not have a public IP address, it cannot be accessed directly from the Internet.

Only resources deployed inside the VPC can establish network communication with the database.

**Benefit**

- Reduces the attack surface.
- Prevents unauthorized Internet access.
- Protects sensitive business information.

---

### Security Groups

Database access is controlled using dedicated Security Groups.

Instead of allowing MySQL access from specific public IP addresses, inbound traffic is restricted to the Security Group associated with the Amazon EC2 application servers.

| Resource | Security Group |
|----------|----------------|
| Application Layer | web-sg |
| Database Layer | portfolio-rds-sg |

Only EC2 instances that belong to **web-sg** are authorized to communicate with Amazon RDS over TCP port **3306**.

This implementation follows AWS networking best practices and avoids unnecessary exposure of the database.

---

### Public Accessibility Disabled

Amazon RDS was configured with:

```text
Public Access = No
```

This ensures that:

- The database endpoint is reachable only from within the Amazon VPC.
- External clients cannot establish direct MySQL connections.
- Database administration must occur through authorized application servers.

---

### Principle of Least Privilege

Network communication was restricted to the minimum permissions required for the application to operate.

The following access model was implemented:

| Source | Destination | Port | Status |
|--------|-------------|------|:------:|
| Internet | Amazon RDS | 3306 | ❌ Denied |
| Amazon EC2 (web-sg) | Amazon RDS | 3306 | ✅ Allowed |

This configuration minimizes unnecessary network exposure while allowing the application to function correctly.

---

### Encryption in Transit

Database communication between Amazon EC2 and Amazon RDS was validated using SSL/TLS encryption.

The connection was established using the Amazon RDS Certificate Authority bundle and verified through an encrypted MySQL session.

Validation confirmed:

- Secure certificate validation.
- Encrypted client-server communication.
- Protected database credentials during authentication.

---

### Database Authentication

Access to the database requires:

- Valid MySQL credentials.
- Network authorization through Security Groups.
- Successful SSL/TLS negotiation.

Unauthorized users cannot establish database sessions even if they know the database endpoint.

---

### Data Protection

Business information stored within the NovaCommerce database includes:

- Customer information
- Product catalog
- Inventory records
- Orders
- Payment information

Protecting this information is essential to maintain confidentiality, integrity, and availability.

Amazon RDS provides automated backups, managed infrastructure, and integrated monitoring services that simplify operational management while improving database resilience.

---

### Security Best Practices Applied

The following AWS security best practices were implemented during this laboratory:

- Deploy databases in private subnets.
- Disable public database access.
- Restrict database communication using Security Groups.
- Follow the Principle of Least Privilege.
- Encrypt database connections using SSL/TLS.
- Separate the application and database into independent tiers.
- Use managed database services instead of self-managed database servers whenever possible.

---

## Cost Optimization

The following decisions were made to keep the laboratory cost-effective while maintaining the required functionality.

| Decision | Benefit |
|----------|---------|
| db.t3.micro instance | Low-cost instance suitable for learning environments. |
| Single-AZ deployment | Reduces infrastructure costs compared to Multi-AZ deployments. |
| gp3 storage | Provides a balance between performance and cost. |
| Minimal allocated storage | Avoids paying for unused capacity. |
| Automatic resource cleanup | Prevents unnecessary charges after completing the lab. |

---

## Best Practices

The following AWS best practices were applied throughout this lab:

- Keep databases in private subnets.
- Restrict database access using Security Groups.
- Follow the Principle of Least Privilege.
- Enable automated backups.
- Use managed database services whenever possible.
- Monitor database performance using Amazon CloudWatch.
- Remove unused cloud resources after completing the lab.

---

## Cleanup

After completing the lab, remove all AWS resources to avoid unnecessary charges.

The cleanup process includes:

1. Delete the Amazon RDS instance.
2. Delete the DB Subnet Group if it is no longer required.
3. Remove custom Security Groups created for the lab.
4. Delete test databases and sample data if applicable.
5. Verify that no billable resources remain in your AWS account.

---

## Key Takeaways

Completing this laboratory provided practical experience in designing and implementing a secure relational database layer using Amazon RDS within an existing AWS cloud environment.

The most valuable learning outcomes include:

- Successfully integrated Amazon RDS into an existing multi-tier cloud architecture.
- Reused networking resources from previous laboratories instead of creating isolated infrastructure.
- Designed a secure database architecture using private subnets.
- Configured Security Groups following the Principle of Least Privilege.
- Established encrypted SSL/TLS communication between Amazon EC2 and Amazon RDS.
- Implemented a complete relational database for the NovaCommerce application.
- Designed normalized database tables using Primary Keys and Foreign Keys.
- Validated database functionality through complete CRUD operations.
- Implemented inventory and payment modules to support realistic e-commerce workflows.
- Executed relational JOIN queries and created reusable database views.
- Applied systematic troubleshooting techniques to resolve networking, DNS, SSL, and connectivity issues.
- Reinforced the importance of infrastructure reuse when building cloud-native applications.
- Improved infrastructure reproducibility by storing database schemas, sample data, views, and connection automation inside version control.

This laboratory transformed the existing cloud infrastructure into a complete three-tier application architecture by introducing the persistence layer required for modern enterprise applications.

---

## Skills Demonstrated

The following technical skills were demonstrated during the implementation of this laboratory.

### AWS Cloud Services

- Amazon RDS
- Amazon EC2
- Amazon VPC
- Security Groups
- DB Subnet Groups
- Amazon CloudWatch
- AWS IAM

---

### Database Administration

- MySQL
- Relational Database Design
- Database Normalization
- Primary Keys
- Foreign Keys
- SQL
- CRUD Operations
- Database Views
- Inventory Management
- Payment Processing

---

### Networking

- Private Subnets
- VPC Networking
- Secure Database Connectivity
- TCP Port Configuration
- DNS Resolution
- SSL/TLS Communication

---

### Security

- Principle of Least Privilege
- Security Groups
- Private Database Deployment
- Encrypted Database Connections
- Certificate Validation

---

### Cloud Architecture

- Three-Tier Architecture
- Persistent Storage Layer
- Infrastructure Reuse
- Separation of Concerns
- Production-Oriented Design

---

### Linux Administration

- SSH
- MariaDB Client
- MySQL Client
- Package Management
- SSL Certificate Installation
- Command-Line Troubleshooting

---

### Troubleshooting

- Network Connectivity
- Security Group Validation
- DNS Resolution
- SSL/TLS Debugging
- Database Connectivity
- Infrastructure Validation
- Root Cause Analysis

---

## Troubleshooting

During the implementation of this laboratory, several real-world issues were encountered and resolved.

Documenting these incidents provides valuable operational knowledge and demonstrates practical troubleshooting skills beyond simply deploying AWS resources.

---

### Issue 1 – SSH Connection Timeout

#### Problem

SSH connections to the Amazon EC2 instance consistently failed with:

```text
ssh: connect to host <public-ip> port 22: Connection timed out
```

Although:

- Security Groups were correctly configured.
- Route Tables were correct.
- Internet Gateway was attached.
- Network ACLs allowed inbound and outbound traffic.
- The EC2 instance was running normally.

#### Root Cause

The Security Group allowed SSH only from the public IP returned by:

```bash
curl https://checkip.amazonaws.com
```

However, the actual source IP used by SSH traffic was different due to ISP routing.

This was confirmed inside Amazon Linux by executing:

```bash
last -i
```

The login history revealed that SSH traffic originated from another public IP address.

#### Resolution

SSH access was temporarily opened from:

```text
0.0.0.0/0
```

After confirming connectivity, the actual source IP was identified and the Security Group was updated accordingly.

#### Lessons Learned

Never assume that the public IP returned by an online service is the same IP used for SSH traffic.

Always validate the actual client IP from the server side before restricting Security Group rules.

---

### Issue 2 – Unknown MySQL Server Host

#### Problem

The MySQL client returned:

```text
ERROR 2005 (HY000):
Unknown MySQL server host
```

#### Root Cause

The Amazon RDS endpoint was typed manually and contained an incorrect character.

The endpoint contained the letter:

```text
o
```

but was accidentally entered as:

```text
0
```

Because DNS names are case-sensitive and character-specific, the hostname could not be resolved.

#### Resolution

The endpoint was copied directly from the Amazon RDS console instead of being typed manually.

DNS resolution immediately succeeded.

#### Lessons Learned

Always copy AWS endpoints directly from the console.

Avoid manually typing long DNS names.

---

### Issue 3 – SSL Parameter Compatibility

#### Problem

The MariaDB client reported:

```text
mysql:
unknown variable 'ssl-mode=VERIFY_IDENTITY'
```

#### Root Cause

Amazon Linux included the MariaDB client rather than the official MySQL client.

The MariaDB client uses different SSL parameters.

#### Resolution

The connection command was updated to use:

```bash
--ssl-ca
--ssl-verify-server-cert
```

instead of:

```bash
--ssl-mode=VERIFY_IDENTITY
```

The SSL/TLS connection was successfully established afterwards.

#### Lessons Learned

Although MySQL and MariaDB are highly compatible, some client parameters differ.

Always verify client compatibility before following generic documentation.

---

### Issue 4 – SSL Certificate Validation

#### Problem

A secure encrypted connection could not be established because the required certificate bundle was not available.

#### Root Cause

The Amazon RDS Certificate Authority bundle had not yet been downloaded to the EC2 instance.

#### Resolution

The official certificate bundle was downloaded:

```bash
curl -o global-bundle.pem \
https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem
```

The MySQL client was then configured to use the downloaded certificate.

#### Lessons Learned

Encrypted database connections require trusted Certificate Authorities.

Using the official AWS certificate ensures secure communication between EC2 and Amazon RDS.

---

### Issue 5 – Database Connectivity Validation

#### Problem

Before executing SQL operations, it was necessary to confirm that the application server could reach Amazon RDS over the private network.

#### Validation

Connectivity was verified through:

- DNS resolution.
- TCP connectivity.
- SSL/TLS negotiation.
- Database authentication.
- SQL execution.

The successful execution of these tests confirmed that:

- Amazon EC2
- Security Groups
- Amazon VPC
- Private Subnets
- Amazon RDS

were all correctly integrated.

---

## Key Troubleshooting Takeaways

The implementation of this laboratory reinforced several important cloud engineering concepts:

- Troubleshooting should always begin with networking before investigating the application.
- Security Groups are often the first component to validate during connectivity issues.
- DNS resolution should be verified before testing database authentication.
- SSL/TLS connectivity requires compatible client software and trusted certificates.
- Validating each infrastructure layer independently significantly reduces troubleshooting time.
- Real-world cloud deployments require systematic investigation rather than assumptions.

---

## References

The following official documentation was used throughout the implementation of this laboratory.

### AWS Documentation

- Amazon RDS User Guide  
  https://docs.aws.amazon.com/rds/

- Amazon EC2 User Guide  
  https://docs.aws.amazon.com/ec2/

- Amazon VPC User Guide  
  https://docs.aws.amazon.com/vpc/

- Amazon CloudWatch User Guide  
  https://docs.aws.amazon.com/cloudwatch/

- AWS IAM User Guide  
  https://docs.aws.amazon.com/iam/

- AWS Well-Architected Framework  
  https://docs.aws.amazon.com/wellarchitected/

---

### Database Documentation

- MySQL Documentation  
  https://dev.mysql.com/doc/

- MariaDB Client Documentation  
  https://mariadb.com/docs/

---

### Security Documentation

- Amazon RDS SSL/TLS Connections  
  https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html

- AWS Security Best Practices  
  https://aws.amazon.com/architecture/security-identity-compliance/